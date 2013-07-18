
module Awestruct
  module Extensions
    class GuideMetadata 

      def initialize()
      end

      def execute(site)
        if site.guide_metadata
          guide_metadata = {}
          site.guide_metadata.each do |k, v|
            s = OpenStruct.new(v)
            
            # add conventions for github
            s.prefix ||= k
            s.github_org ||= 'jboss-jdf'
            s.module ||= k
            s.github_repo ||= s.module
            s.github_repo_url ||= "http://github.com/#{s.github_org}/#{s.github_repo}"
            s.git_branch ||= s.version
            s.clone_url ||= "git://github.com/#{s.github_org}/#{s.github_repo}.git"
            s.clone_command ||= "git clone --recursive #{s.clone_url} --branch #{s.git_branch}"
            s.github_source_zip ||= "#{s.github_repo_url}/zipball/#{s.git_branch}"
            s.github_url ||=  "#{s.github_repo_url}/tree/#{s.git_branch}"

            # Default basic info
            s.index_label ||= "Guides Index"
            s.downloads_label ||= "Get the source"

            # Alternate formats conventions
            s.alternate_formats_base_url ||= "http://download.jboss.org/jdf/#{s.version}"

            # build alternate formats
            af_hash = s.alternate_formats
            s.alternate_formats = af_hash ? [] : nil
            if af_hash
              af_hash.each do |k1, v1|
                af = OpenStruct.new(v1)
                af.format ||= k1
                
                # add conventions
                af.download_url ||= "#{s.alternate_formats_base_url}/#{s.module}-#{s.version}.#{af.format}"

                s.alternate_formats << af
              end
            end

            # build guide metadata
            guides_hash = s.guides
            s.guides = guides_hash ? {} : nil
            if guides_hash
              guides_hash.each_with_index do |(k1, v1), index|
                guide = OpenStruct.new(v1)
                guide.name = k1
                guide.position = index
                # add conventions
                s.guides[guide.name.to_s] = guide
              end
            end

            guide_metadata[s.prefix] = s
          end
          site.guide_metadata = guide_metadata
        end
      end

    end
  end
end
