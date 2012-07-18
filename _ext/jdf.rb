# encoding: utf-8
require 'git'
require 'fileutils'
require 'rexml/document'

class Artifact
  attr_reader :name, :coordinates

  def initialize(name, coordinates)
    @name = name
    @coordinates = coordinates
  end

  class Coordinates
    attr_reader :groupId, :artifactId, :packaging, :version
    def initialize(groupId, artifactId, packaging = :jar, version = nil)
      @groupId = groupId
      @artifactId = artifactId
      @packaging = packaging.nil? ? :jar : packaging.to_sym
      @version = version
    end

    def self.parse(coordinates_str)
      # The * spreads the array across the arguments of the constructor
      new(*coordinates_str.split(':'))
    end

    def to_maven_dep(opts = {})
      scope = opts[:scope] || :compile
      include_version = opts[:include_version].nil? ? true : opts[:include_version]
      buf = "<dependency>\n".
          concat("  <groupId>#{@groupId}</groupId>\n").
          concat("  <artifactId>#{@artifactId}</artifactId>\n")
      buf.concat("  <type>#{@packaging}</type>\n") if !packaging.to_sym.eql? :jar
      buf.concat("  <version>#{@version}</version>\n") if include_version and !version.nil?
      buf.concat("  <scope>#{scope}</scope>\n") if !scope.to_sym.eql? :compile
      buf.concat("</dependency>")
    end

    def to_url(base_url = 'http://repo1.maven.org/maven2')
      [base_url, @groupId.gsub('.', '/'), @artifactId, @version,
          @artifactId + '-' + @version + '.' + @packaging.to_s] * '/'
    end

    def to_pom_url(base_url = 'http://repo1.maven.org/maven2')
      [base_url, @groupId.gsub('.', '/'), @artifactId, @version,
          @artifactId + '-' + @version + '.' + @packaging.to_s].join('/').gsub(/\.jar$/, '.pom')
    end

    def to_relative
      [@artifactId, @packaging.to_s, @version] * ':'
    end

    def to_s
      [@groupId, @artifactId, @packaging.to_s, @version] * ':'
    end
  end
end

module Awestruct
  module Handlers
    class AsciidocHandler

      def rendered_content(context, with_layouts=true)
        out_file="#{site.tmp_dir}/asciidoc#{relative_source_path.gsub(/\.([^.]+)$/, '.html')}"
        if !File.exists?(out_file)
          FileUtils.mkdir_p(File.dirname(out_file))
          puts "Processing asciidoc #{relative_source_path} -> #{out_file}"
          cmd="asciidoc -b html5 -a pygments -a icons -a iconsdir='#{site.base_url}/images' -a imagesdir='../' -o '#{out_file}' #{context.page.source_path}"
          execute_shell(cmd)
        end
        output = File.open(out_file).read

        extract_metadata(context.page, output)
       
      end

      def extract_metadata(page, output)
        html = Nokogiri::HTML(output)
        # Asciidoc renders a load of stuff at the top of the page, which we need to extract bits of (e.g. author, title) but we want to dump it for rendering
        page.source_title = html.css("h1").first.text
        guide_content = html.css('div#content').first 
        guide_content['id'] = 'guide-content'
        guide_content['class'] = 'asciidoc'
        # Extract authors
        author = html.css('span#author').first
        if author
          page.source_author = [ author.text ]
        end

        # rebuild links
        guide_content.css('a').each do |a|
          if a['href'] =~ /^#(\w*)-(\w*)$/
            a['href'] = "../#{$1}/##{$1}-#{$2}"
          end
        end

        guide_content.to_html
      end

    end
  end
end

module Awestruct
  module Handlers
    class MarkdownHandler

      def rendered_content(context, with_layouts=true)
        doc = RDiscount.new( delegate.rendered_content( context, with_layouts ) )
        extract_metadata(context.page, doc.to_html)
      end

      def extract_metadata(page, output)
        
        html = Nokogiri::HTML(output)

        # Strip out html and body
        guide_content = html.css('body').first
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
        end
        
        # Strip out title
        h1 = guide_content.css('h1').first
        if h1
          page.source_title = h1.text
          h1.remove
        end

        metadata = guide_content.css('p#metadata').remove

        guide_content.css('h2').each do |header_html|
          link_id = header_html.inner_html.gsub(' ', '_').gsub('&#8217;', '_').gsub(/[\(\)\.!]/, '').gsub(/\?/, '').downcase
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
          page.send("source_#{tag.downcase}=".to_sym, s)
        end
      end

      def find_split(p, tag)
        s = find(p, tag)
        if s
          return s.split(',').sort 
        end
      end

    end
  end
end


module Awestruct::Extensions::Repository::Visitors
  module Clone
    include Base

    def visit(repository, site)
      repos_dir = nil
      if site.repos_dir
        repos_dir = site.repos_dir
      else
        repos_dir = File.join(site.tmp_dir, 'repos')
      end
      if !File.directory? repos_dir
        FileUtils.mkdir_p(repos_dir)      
      end
      clone_dir = File.join(repos_dir, repository.path)
      rc = nil
      if !File.directory? clone_dir
        puts "Cloning repository #{repository.clone_url} -> #{clone_dir}"
        rc = Git.clone(repository.clone_url, clone_dir)
        if repository.master_branch.nil?
          rc.checkout(repository.master_branch)
        else
          repository.master_branch = rc.current_branch
        end
      else
        puts "Using cloned repository #{clone_dir}"
        rc = Git.open(clone_dir)
        master_branch = repository.master_branch
        if master_branch.nil?
          master_branch = rc.branches.find{|b| !b.remote and !b.name.eql? '(no branch)'}.name
          repository.master_branch = master_branch
        end
        rc.checkout(master_branch)
        # nil argument required to work around bug in git library
        rc.pull('origin', ['origin', master_branch] * '/', nil)
      end
      repository.clone_dir = clone_dir
      repository.client = rc
    end
  end

  module RepositoryHelpers
    # Retrieves the contributors between the two commits, filtering
    # by the relative path, if present
    def self.resolve_contributors_between(site, repository, sha1, sha2)
      range_author_index = {}
      RepositoryHelpers.resolve_commits_between(repository, sha1, sha2).map {|c|
        # we'll use email as the key to finding their identity; the sha we just need temporarily
        OpenStruct.new({:name => c.author.name, :email => c.author.email.downcase, :commits => 0, :sha => c.sha})
      }.each {|e|
        # This loop both grabs unique authors by email and counts their commits
        if !range_author_index.has_key? e.email
          range_author_index[e.email] = e
        end
        range_author_index[e.email].commits += 1
      }
      
      range_author_index.values.each {|e|
        # this loop registers author in global index if not present
        if repository.host.eql? 'github.com'
          site.git_author_index[e.email] ||= OpenStruct.new({
            :email => e.email,
            :name => e.name,
            :sample_commit_sha => e.sha,
            :sample_commit_url => RepositoryHelpers.build_commit_url(repository, e.sha, 'json'),
            :commits => 0,
            :repositories => []
          })
          site.git_author_index[e.email].commits += e.commits
          site.git_author_index[e.email].repositories |= [repository.http_url]
        end
        e.delete_field('sha')
      }.sort {|a, b| a.name <=> b.name}
    end

    # Retrieves the commits in the range, filtered on the relative
    # path in the repository, if present
    def self.resolve_commits_between(repository, sha1, sha2)
      rc = repository.client
      log = rc.log(nil).path(repository.relative_path)
      if sha1.nil?
        log = log.object(sha2)
      else
        log = log.between(sha1, sha2)
      end
    end

    def self.build_commit_url(repository, sha, ext)
      repository.http_url + '/commit/' + sha + '.' + ext
    end
  end

  # SEMI-HACK think about how best to curate & display info about these special repos
  # FIXME at least try to make GenericMavenComponent build on this one; perhaps a website component?
  module GenericComponent
    include Base
    def handles(repository)
	true      
    end

    def visit(repository, site)
      rc = repository.client
      c = OpenStruct.new({
        :repository => repository,
        :basepath => repository.path.eql?(repository.owner) ? repository.path : repository.path.sub(/^#{repository.owner}-/, ''),
        :owner => repository.owner,
        :name => repository.name,
        :desc => repository.desc,
        :contributors => []
      })
      # FIXME not dry (from below)!
      RepositoryHelpers.resolve_contributors_between(site, repository, nil, rc.revparse('HEAD')).each do |contrib|
        i = c.contributors.index {|n| n.email == contrib.email}
        if i.nil?
          c.contributors << contrib
        else
          c.contributors[i].commits += contrib.commits
        end
      end
    end
  end

end
