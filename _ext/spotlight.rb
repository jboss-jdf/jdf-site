# Extension to handle templating external content
module Awestruct::Extensions
  class Spotlight 

    def initialize(path_prefix, opts = {})
      @path_prefix = path_prefix
    end

    def execute(site)
      spotlights = []
      site.pages.each do |page|
        if ( page.relative_source_path =~ /^#{@path_prefix}\// ) 
          spotlight = OpenStruct.new({
            :content=>page.content,
            :weight=>page.weight
          })
          spotlights << spotlight
          page.output_path = page.output_path.gsub(/\.html$/, '.txt')           
        end
      end
      site.spotlights = spotlights
    end

  end
end
