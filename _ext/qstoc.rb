
module Awestruct
  module Extensions
    class QSTOC

      def initialize(path_prefix)
        @path_prefix = path_prefix
      end

      def transform(transformers)
        transformers << WriteToc.new
      end


      def execute(site)
        site.pages.each do |page|
        if page.relative_source_path =~ /^#{@path_prefix}\/[^\/]+$/ && page.rendered_content
          qs_toc_content = ''
          if site.guides[@path_prefix]
            site.guides[@path_prefix].each do |guide|
              if guide.name
                qs_toc_content += "<tr><td align='left'><a href='#{site.base_url}#{guide.url}' title='#{guide.name}'>#{guide.name}</td><td align='left'>#{split(guide.technologies)}</td><td align='left'>#{guide.summary}</td><td align='left'>#{guide.level}</td><td align='left'>#{split(guide.prerequisites)}</td></tr>"
              end
            end
            page.qs_toc = "<table><thead><tr><th align='left'><strong>Quickstart Name</strong></th><th align='left'><strong>Demonstrated Technologies</strong></th><th align='left'><strong>Description</strong></th><th align='left'><strong>Experience Level Required</strong></th><th align='left'><strong>Prerequisites</strong></th></tr></thead><tbody>#{qs_toc_content}</table></table>"
            end
          end 
        end
      end

      def split(s)
        if s
          return ' '.concat(s.map{|u| u} * ', ')
        else
          return ''
        end
      end

    end

    class WriteToc
    
      def transform(site, page, rendered)
        if page.qs_toc
          rendered.gsub("\[TOC-quickstart\]", page.qs_toc)
        else
          rendered
        end
      end

    end
  end
end
