require 'net/http'
require 'net/https'
require 'yaml'

module Awestruct
  module Extensions
    module StacksHelper

      def get_label_content(array,label)
        index = array.index(value);
        content = nil;
        array.each do |v|
          if (v != nil)
            content = v[label] ;
          end
        end
        return content;
      end

    end

    class Stacks

      def initialize(stacks_source='')
        @stacks_source = stacks_source
      end

      def execute(site)
        uri = URI(@stacks_source)
       	http = Net::HTTP.new(uri.host, uri.port)
	      http.use_ssl = true
	      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
	      http.start 
	      request = Net::HTTP::Get.new(uri.request_uri)
	      response = http.request(request)
	      stacks_parsed = YAML.load(response.body)

	      available_boms = mount_boms(stacks_parsed['availableBoms'])
        available_bom_versions = mount_bom_versions(stacks_parsed['availableBomVersions'])
	      available_runtimes = mount_runtimes(stacks_parsed['availableRuntimes'])
        available_archetypes = mount_archetypes(stacks_parsed['availableArchetypes'])
        available_archetype_versions = mount_archetype_versions(stacks_parsed['availableArchetypeVersions'])
	      minor_releases = mount_minor_releases(stacks_parsed['minorReleases'])
	      major_releases = mount_major_releases(stacks_parsed['majorReleases'])
        stacks = JBoss::Stacks.new(
          available_boms,
          available_bom_versions,
          available_archetypes,
          available_archetype_versions,
          available_runtimes,
          major_releases,
          minor_releases
        )
      	site.stacks = stacks
      end

      def mount_archetype_version(version_item)
        JBoss::ArchetypeVersion.new(
          mount_archetype(version_item['archetype']),
          version_item['version'],
          version_item['labels']
        )      
      end

      def mount_archetype_versions(archetype_versions_item)
        archetype_versions = []
        archetype_versions_item.each do |version_item|
          archetype_version_item = mount_archetype_version(version_item)
          archetype_versions << archetype_version_item
        end
        return archetype_versions
      end

      def mount_bom_version(version_item)
        JBoss::BomVersion.new(
          mount_bom(version_item['bom']),
          version_item['version'],
          version_item['labels']
        )      
      end

      def mount_bom_versions(bom_versions_item)
        bom_versions = []
        bom_versions_item.each do |version_item|
          bom_version_item = mount_bom_version(version_item)
          bom_versions << bom_version_item
        end
        return bom_versions
      end

      def mount_runtime(runtime_item)
        JBoss::Runtime.new(
          runtime_item['name'],
          runtime_item['version'],
          runtime_item['type'],
          runtime_item['url'], 
          runtime_item['labels'],
          mount_bom_versions(runtime_item['boms']),
          mount_bom_version(runtime_item['defaultBom']),
          mount_archetype_version(runtime_item['defaultArchetype']),
          mount_archetype_versions(runtime_item['archetypes'])
        )
      end     

      def mount_runtimes(runtimes)
        available_runtimes = []
        runtimes.each do |runtime_item|
          runtime = mount_runtime(runtime_item)
          available_runtimes << runtime
        end
        return  available_runtimes
      end
 
      def mount_bom(bom_item)
        JBoss::Bom.new(
          bom_item['name'],  
          bom_item['description'], 
      	  bom_item['groupId'], 
          bom_item['artifactId'], 
          bom_item['recommendedVersion'] 
    	)
      end

      def mount_boms(boms)
        available_boms = []
      	boms.each do |bom_item| 
      	  bom = mount_bom(bom_item)
    	    available_boms << bom
      	end
      	return available_boms
      end

      def mount_major_release(major_release)
        JBoss::MajorRelease.new(
          major_release['name'],
          major_release['version'],
          major_release['recommendedRuntime'],
          mount_minor_releases(major_release['minorReleases'])
      )
      end

      def mount_major_releases(mrs)
        major_releases = []
        mrs.each do |mr_item|
          major_release = mount_major_release(mr_item)
          major_releases << major_release
        end
	      return major_releases
      end

      def mount_minor_release(minor_release)
        JBoss::MinorRelease.new(
          minor_release['name'],
          minor_release['version'],
          mount_runtime(minor_release['recommendedRuntime'])
      	)
      end

      def mount_minor_releases(mrs)
        minor_releases = []
        mrs.each do |mr_item|
          minor_release = mount_minor_release(mr_item)
          minor_releases << minor_release
        end
        return minor_releases
      end

      def mount_archetype(archetype)
        JBoss::Archetype.new(
          archetype['name'],
          archetype['description'],
          archetype['groupId'],
          archetype['artifactId'],
          archetype['recommendedVersion']
        )
      end

      def mount_archetypes(as)
        available_archetypes = []
        as.each do |as_item|
          archetype = mount_archetype(as_item)
          available_archetypes << archetype
        end
        return available_archetypes
      end

    end #End Class
  end #End module Extensions
end #End module Awestruct

module JBoss
  class Stacks
    attr_reader  :availableBoms, :availableBomVersions, :availableArchetypes, :availableArchetypeVersions, :availableRuntimes, :majorReleases, :minorReleases

	  def initialize(availableBoms, availableBomVersions, availableArchetypes, availableArchetypeVersions, availableRuntimes, majorReleases, minorReleases)
		  @availableBoms = availableBoms
      @availableBomVersions = availableBomVersions
		  @availableArchetypes = availableArchetypes
      @availableArchetypeVersions = availableArchetypeVersions
		  @availableRuntimes = availableRuntimes
		  @majorReleases = majorReleases
		  @minorReleases = minorReleases
	  end
  end

  class BomVersion
    attr_reader :bom, :version, :labels

    def initialize(bom, version, labels)
      @bom = bom
      @version = version
      @labels = labels
    end

    def link_id
      (@bom.groupId + @bom.artifactId + @version).gsub('.','').gsub('-','');
    end

  end

  class Bom
	  attr_reader :name, :description, :groupId, :artifactId, :recommendedVersion

	  def initialize(name, description, groupId, artifactId, recommendedVersion)
		  @name = name
		  @description = description
		  @groupId = groupId
		  @artifactId = artifactId
		  @recommendedVersion = recommendedVersion
	  end
  
    def link_id
      (@groupId + @artifactId + @recommendedVersion).gsub('.','').gsub('-','');
    end

  end

  class Runtime
    attr_reader :name, :version, :type, :url, :labels, :boms, :defaultBom, :defaultArchetype, :archetypes

	  def initialize(name, version, type, url, labels, boms, defaultBom, defaultArchetype, archetypes)
		  @name = name
		  @version = version
		  @type = type
		  @url = url
		  @labels = labels
		  @boms = boms
		  @defaultBom = defaultBom
		  @defaultArchetype = defaultArchetype
		  @archetypes = archetypes
	  end
  end

  class ArchetypeVersion
    attr_reader :archetype, :version, :labels

    def initialize(archetype, version, labels)
      @archetype = archetype
      @version = version
      @labels = labels
    end

    def link_id
      (@archetype.groupId + @archetype.artifactId + @version).gsub('.','').gsub('-','');
    end

  end

  class Archetype
    attr_reader :name, :description, :groupId, :artifactId, :recommendedVersion

    def initialize(name, description, groupId, artifactId, recommendedVersion)
      @name = name
      @description = description
      @groupId = groupId
      @artifactId = artifactId
      @recommendedVersion = recommendedVersion
    end

    def link_id
      (@groupId + @artifactId + @recommendedVersion).gsub('.','').gsub('-','');
    end

  end

  class MajorRelease
	  attr_reader :name, :version, :recommendedRuntime, :minorReleases

	  def initialize(name, version, recommendedRuntime, minorReleases)
		  @name = name
		  @version = version
		  @recommendedRuntime = recommendedRuntime
		  @minorReleases = minorReleases
	  end
  end 

  class MinorRelease
	  attr_reader :name, :version, :recommendedRuntime

	  def initialize(name, version, recommendedRuntime)
		  @name = name
		  @version = version
		  @recommendedRuntime = recommendedRuntime
	  end
  end 

end

