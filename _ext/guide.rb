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

          guides = []

          # Load any metadata parsed for this set of guides
          metadata = site.guide_metadata[@path_prefix]
          
          site.pages.each do |page|
            if ( page.relative_source_path =~ /^#{@path_prefix}\/?(.*?)([^\/]*)#{@suffix}$/ )
              subdir = $1
              name = $2
              
              if !metadata || !metadata.guides || metadata.guides.key?(name)
                # Note that calling page.content causes the source to be parsed and metadata extracted
                # we need to do this early!
                html = Nokogiri::HTML(page.content)                

                guide = OpenStruct.new

                # Attach the guide to the page, so we can reference it later
                page.guide = guide

                guide.name = name 
                guide.metadata = metadata
                guide.dir = subdir
                guide.path_prefix = @path_prefix
                guide.src_root = root_dir
                guide.src_relative_path = guide.dir + page.guide.name + @suffix

                page.layout = @layout

                site.engine.set_urls([page])
                guide.url = page.url
               
                # Extract metadata from git
                guide.changes = page_changes(guide, @num_changes)
                guide.contributors = page_contributors(guide, @num_contrib_changes, guide.authors)

                # Different formats use different metadata formats, so is extracted in a handler
                guide.title = page.source_title 
                guide.authors = page.source_authors
                guide.technologies = page.source_technologies 
                guide.level = page.source_level
                guide.summary = page.source_summary
                guide.prerequisites = page.source_prerequisites
                
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

      end

      ##
      # Returns a Array of unique contributors.name's based on the Git commit history for the given page.
      # Assumes guides are brought in as submodules so opens git rooted in the page's dir
      # The Array is ordered by number of commits done by the contributors.
      # Any authors are removed from the contributor list
      def page_contributors(guide, size, authors)
        contributors = Hash.new
        g = Git.open(guide.src_root)
        g.log(size == -1 ? nil : size).path(guide.src_relative_path).each do |c|
          if !authors || authors.count(c.author.name) == 0
            if contributors[c.author.name]
              contributors[c.author.name] = contributors[c.author.name] + 1
            elsif
              contributors[c.author.name] = 1
            end
          end
        end
        contributors.size == 0 ? nil : contributors.sort{|a, b| b[1] <=> a[1]}.map{|x| x[0]}
      end

      def page_changes(guide, size)
        changes = []
        g = Git.open(guide.src_root)
        g.log(size == -1 ? nil : size).path(guide.src_relative_path).each do |c|
          changes << Change.new(c.sha, c.author.name, c.author.date, c.message.split(/\n/)[0].chomp('.').capitalize)
        end
        if changes.length == 0
          changes << Change.new('UNTRACKED', 'You', Time.now, 'Not yet committed')
        end
        changes
      end

    end
  end
end
