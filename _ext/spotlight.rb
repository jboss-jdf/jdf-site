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
            :title=>page.title,
            :content=>page.content
          })
          for i in 0..page.weight
            spotlights << spotlight
          end
        end
      end
      site.spotlights=spotlights.shuffle
    end

  end
end
