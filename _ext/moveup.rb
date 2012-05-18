module Awestruct
  module Extensions
    class MoveUp

      def initialize(path_prefix, containing_dir)
        @path_prefix = path_prefix
        @containing_dir = containing_dir
      end

      def execute(site)
        site.pages.each do |page|
          if ( page.inhibit_indexifier )
            # skip it!
          elsif( page.output_path =~ /^#{@path_prefix}\/(.*)(#{@containing_dir}\/index.html)$/ )
            page.output_path = page.output_path.gsub( /#{@containing_dir}\/index.html$/, 'index.html' )
          end
        end
      end

    end
  end
end
