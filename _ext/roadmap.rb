module Awestruct
  module Extensions
    class Roadmap

      def initialize(path_prefix='', assign_to=:roadmaps)
        @path_prefix = path_prefix
        @assign_to   = assign_to
      end

      def execute(site)
        roadmaps = []

        site.pages.each do |page|
          if page.relative_source_path =~ /^#{@path_prefix}\/([0-9a-z\.-]+)\..*$/
            version  = $1
            roadmap = OpenStruct.new({
              :content => page.content,
              :version => version,
              :tagline => page.tagline,
              :release_date => Date.strptime(page.release_date.to_s, '%Y-%m-%d'),
              :released => page.released,
              :highlights => [],
              :downloads => []
            })
            if page.highlights
              page.highlights.each do |ph|
                highlight = OpenStruct.new({
                  :label => ph[0],
                  :url => ph[1]
                })
                if highlight.url && highlight.url !~ /^http:\/\//
                  highlight.url = site.base_url + highlight.url
                end
                roadmap.highlights << highlight
              end
            end
            if page.downloads
              page.downloads.each do |ph|
                download = OpenStruct.new({
                  :label => ph[0],
                  :url => ph[1]
                })
                if download.url &&  download.url !~ /^http:\/\//
                  download.url = site.base_url + download.url
                end
                roadmap.downloads << download
              end
            end
            roadmaps << roadmap
          end
        end
        roadmaps = roadmaps.sort_by{|each| [each.release_date ] }.reverse

        site.send( "#{@assign_to}=", roadmaps )
      end

    end
  end
end
