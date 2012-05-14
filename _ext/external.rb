# Extension to handle templating external content
module Awestruct::Extensions
  class External

    def initialize(path_prefix, layout, opts = {})
      @path_prefix = path_prefix
      @layout = layout
    end

    def execute(site)
      site.pages.each do |page|
        if ( page.relative_source_path =~ /^#{@path_prefix}\// ) 
          # Set the layout
          page.layout=@layout
        end
      end
    end

  end
end
