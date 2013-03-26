module Awestruct
  module Extensions
    class Maven

      def initialize(path_prefix)
        @path_prefix = path_prefix
      end

      def execute(site)
        root_dir = site.dir.to_s.match(/^(.*[^\/?])([\/]?)$/)[1] + @path_prefix
        pom_file = root_dir + "/pom.xml"
        cmd = "mvn -f '#{pom_file}' clean site"
        puts "Executing #{cmd}"
        puts `#{cmd} `
        puts "Maven site geneated for #{@path_prefix}"
      end
    end #End Class
  end #End module Extensions
end #End module Awestruct

