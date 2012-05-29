module Awestruct
  module Extensions
    class OrderNameFixer 

      def initialize(path_prefix)
        @path_prefix = path_prefix
      end

      def execute(site)
        site.pages.each do |page|
          if ( page.inhibit_indexifier )
            # skip it!
          elsif( page.output_path =~ /^#{@path_prefix}\/([0-9]+-).*\/index.html$/ )
            page.output_path = page.output_path.gsub( /#{$1}/, '' )
          end
        end
      end

    end
  end
end
