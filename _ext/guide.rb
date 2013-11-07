require 'nokogiri'
require 'open-uri'

module Awestruct
  module Extensions
    module Guide
      Change = Struct.new(:sha, :author, :date, :message)

      class Index
        include Guide

        def initialize(path_prefix, suffix, opts = {})
          @path_prefix = path_prefix
          @suffix = suffix
          @num_changes = opts[:num_changes] || 15
          @num_contrib_changes = opts[:num_contrib_changes] || -1
          @layout = opts[:layout] || 'guide'
        end

        def transform(transformers)
        end

        def execute(site)
          # Initialize site.guides if not already set up
          site.guides ||= {}

          root_dir = site.dir.to_s.match(/^(.*[^\/?])([\/]?)$/)[1] + @path_prefix
          git_root_dir = find_git_root(root_dir)
          git_sub_dir = root_dir.gsub(/#{git_root_dir}[\/]?/, '')
          guides = []

          # Load any metadata parsed for this set of guides
          metadata = site.guide_metadata[@path_prefix]

          #Load ignore-file from guide metadata
          ignore_content = nil
          if (metadata.ignore_file)
            ignore_file = File.join(root_dir, metadata.ignore_file)
            file = File.open(ignore_file , "rb")
            ignore_content = file.read
          end

          site.pages.each do |page|
            if ( page.relative_source_path =~ /^#{@path_prefix}\/?(.*?)([^\/]*)#{@suffix}$/ )
              subdir = $1
              name = $2

              #Skip based on ignore-file content
              unless name.empty? || ignore_content.nil? || !ignore_content.include?(name)
                next;
              end

              if  !metadata || !metadata.guides || metadata.guides.key?(name)

                # Note that calling page.content causes the source to be parsed
                html = Nokogiri::HTML(page.content)

                #extract metadata from different formats
                if ( page.content_syntax == :asciidoc )
                  page.modified_content = extract_metadata_from_asciidoc(page, html)
                elsif (page.content_syntax == :markdown)
                  page.modified_content = extract_metadata_from_markdown(page, html)
                else
                  page.modified_content = page.content
                end

                guide = OpenStruct.new

                # Attach the guide to the page, so we can reference it later
                page.guide = guide

                guide.name = name
                guide.metadata = metadata
                guide.dir = subdir
                guide.path_prefix = @path_prefix
                guide.src_root = root_dir
                guide.git_root = git_root_dir
                guide.src_relative_path = guide.dir + page.guide.name + @suffix

                #Remove the "/" - Git log does not work with /FILE.* on relative path
                git_relative_path = (guide.src_relative_path.start_with?('/') ? guide.src_relative_path[1..-1] : guide.src_relative_path)

                guide.git_relative_path = git_sub_dir + (git_sub_dir.length > 0 ? "/" : "") + git_relative_path

                page.layout = @layout

                site.engine.set_urls([page])
                guide.url = page.url

                # Different formats use different metadata formats
                guide.title = page.title ? page.title : page.source_title

                if page.source_author
                  guide.authors = []
                  page.source_author.each do |a|
                    guide.authors << site.identities.lookup_by_name(a)
                  end
                  if !guide.authors.empty? && guide.authors[0] != nil
                    page.author = guide.authors[0].github_id
                  end
                end
                guide.technologies = page.source_technologies
                guide.level = page.source_level
                guide.summary = page.source_summary
                guide.prerequisites = page.source_prerequisites
                guide.target_product = page.source_target_product

                guide.meta = page.guide.summary
                if guide.technologies
                  guide.meta += ". Technologies covered include".concat(guide.technologies.map{|u| u} * ', ')
                end
                if guide.level
                  guide.meta += ". Aimed at " + guide.level.downcase + " users."
                end

                # Extract metadata from git
                guide.changes = page_changes(guide, site.identities, @num_changes)
                guide.contributors = page_contributors(guide, site.identities, @num_contrib_changes, guide.authors)

                #collect peoble (authors, contributos, committers) that acted on this guide
                people = []
                if (guide.authors)
                  people += guide.authors.dup
                end
                if (guide.contributors)
                  people += guide.contributors.dup
                end
                guide.changes.each do |change|
                  people << change.author
                end
                guide.people = people.uniq

                # Extract chapter info from the page
                guide.chapters = []

                html.css('h2').each do |header_html|
                  chapter = OpenStruct.new
                  chapter.text = header_html.inner_html
                  chapter.link_id = header_html.attribute('id')
                  guide.chapters << chapter
                end

                # make "extra chapters" a setting of the extension?
                chapter = OpenStruct.new
                chapter.text = 'Share the Knowledge'
                chapter.link_id = 'share'
                guide.chapters << chapter

                if guide.metadata && guide.metadata.guides
                  # Guide metadata exists, which specifies ordering
                  v = metadata.guides[guide.name]
                  guides[v.position] = guide
                  guide.summary = v.summary
                else
                  guides << guide
                end

                page.guides = guides
              end
            end
          end
          site.guides[@path_prefix] = guides
        end

        def extract_metadata_from_asciidoc(page, content)
          # Asciidoc renders a load of stuff at the top of the page, which we need to extract bits of (e.g. author, title) but we want to dump it for rendering
          page.source_title = page.title
          guide_content = content.css('body').first
          guide_content['id'] = 'content'
          guide_content['class'] = 'asciidoc'

          # Extract authors
          author = page.author
          if author
            page.source_author = [ author ]
          end
          page.source_summary = first_x_words(guide_content.css('p').first.text, 25, '').gsub("\n", '')

          # rebuild links
          guide_content.css('a').each do |a|
            if a['href'] =~ /^#(\w*)-(\w*)$/
              a['href'] = "../#{$1}/##{$1}-#{$2}"
            end
          end

          guide_content.to_html
        end

        def first_x_words(str,n=20,finish='&hellip;')
          str.split(' ')[0,n].inject{|sum,word| sum + ' ' + word} + finish
        end

        def extract_metadata_from_markdown(page, content)

          # Strip out html and body
          guide_content = content.css('body').first
          guide_content.name = 'div'
          guide_content['id'] = 'guide-content'
          guide_content['class'] = 'markdown'

          # Markdown doesn't have an metadata syntax, so all we can do is pray ;-)
          # Look for a paragraph that contains tags, which we define by convention
          # Remove if found
          guide_content.css('p').each do |p|
            extract(page, p, 'Author', true)
            extract(page, p, 'Technologies', true)
            extract(page, p, 'Level')
            extract(page, p, 'Summary')
            extract(page, p, 'Prerequisites', true)
            extract(page, p, 'Target Product' )
          end

          # Strip out title
          h1 = guide_content.css('h1').first
          if h1
            page.source_title = h1.text
            h1.remove
          end

          metadata = guide_content.css('p#metadata').remove

          guide_content.css('h2').each do |header_html|
            link_id = header_html.inner_html.gsub(' ', '-').gsub('&#8217;', '-').gsub(/[\(\)\.!]/, '').gsub(/\?/, '').downcase
            header_html['id'] = link_id
          end

          # rebuild links
          guide_content.css('a').each do |a|
            if a['href'] =~ /^(.*\/)README.md(.*)$/
              a['href'] = $1 + $2
            end
          end

          guide_content.to_html
        end

        def find(p, tag)
          if p.text
            r = p.text[/^(#{tag}: )(.+)$/, 2]
            if r
              p['id'] = 'metadata'
              return r
            end
          end
        end

        def extract(page, p, tag, split=false)
          if split
            s = find_split(p, tag)
          else
            s = find(p, tag)
          end
          if s
            page.send("source_#{tag.downcase}=".sub(' ','_').to_sym, s)
          end
        end

        def find_split(p, tag)
          s = find(p, tag)
          if s
            return s.split(',').sort
          end
        end

      end
      ##
      # Returns a Array of unique contributors.github_id's based on the Git commit history for the given page.
      # Assumes guides are brought in as submodules so opens git rooted in the page's dir
      # The Array is ordered by number of commits done by the contributors.
      # Any authors are removed from the contributor list
      def page_contributors(guide, identities, size, authors)
        contributors = Hash.new
        g = Git.open(guide.git_root)
        g.log(size == -1 ? nil : size).path(guide.git_relative_path).each do |c|
          user = identities.lookup_by_email(c.author.email)
          user = user ? user : c.author.name
          if !authors || authors.count(user) == 0
            if contributors[user]
              contributors[user] = contributors[user] + 1
            elsif
              contributors[user] = 1
            end
          end
        end
        contributors.size == 0 ? nil : contributors.sort{|a, b| b[1] <=> a[1]}.map{|x| x[0]}
      end

      def page_changes(guide, identities, size)
        changes = []
        g = Git.open(guide.git_root)
        g.log(size == -1 ? nil : size).path(guide.git_relative_path).each do |c|
          user = identities.lookup_by_email(c.author.email)
          user = user ? user : c.author.name
          changes << Change.new(c.sha, user, c.author.date, c.message.split(/\n/)[0].chomp('.').capitalize)
        end
        if changes.length == 0
          changes << Change.new('UNTRACKED', 'You', Time.now, 'Not yet committed')
        end
        changes
      end

      def find_git_root(dir)
        if File.directory?(dir)
          if File.exists?(File.expand_path(".git", dir))
            dir
          else
            dir = File.expand_path("../", dir)
            find_git_root(dir)
          end
        end
      end

    end
  end
end
