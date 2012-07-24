require 'net/http'
require 'net/https'
require 'yaml'

# identacao
# nomenclatura 
# scopo das variaveis

module Awestruct
  module Extensions
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
	      #TODO Mount Archetypes
	      available_boms = mount_boms(stacks_parsed['availableBoms'])
	      available_runtimes = mount_runtimes(stacks_parsed['availableRuntimes'])
	      minor_releases = mount_minor_releases(stacks_parsed['minorReleases'])
	      major_releases = mount_major_releases(stacks_parsed['majorReleases'])
        stacks = JBoss::Stacks.new(
          available_boms,
          nil,
          available_runtimes,
          major_releases,
          minor_releases
        )
      	site.stacks = stacks
      end

      def mount_runtime(runtime_item)
        JBoss::Runtime.new(
          runtime_item['name'],
          runtime_item['version'],
          runtime_item['type'],
          runtime_item['url'], 
          runtime_item['labels'],
          mount_boms(runtime_item['boms']),
          mount_bom(runtime_item['defaultBom']),
          nil,
          nil
      	  #TODO Mount Archetypes
        )
      end     

      def mount_runtimes(runtimes)
        availableRuntimes = []
        runtimes.each do |runtime_item|
          runtime = mount_runtime(runtime_item)
          availableRuntimes << runtime
        end
        return  availableRuntimes
      end
 
      def mount_bom(bom_item)
        JBoss::Bom.new(
          bom_item['name'],  
          bom_item['description'], 
      	  bom_item['groupId'], 
          bom_item['artifactId'], 
          bom_item['recommendedVersion'], 
          bom_item['availableVersions'], 
          bom_item['labels']
	)
      end

      def mount_boms(boms)
        availableBoms = []
      	boms.each do |bom_item| 
      	  bom = mount_bom(bom_item)
    	    availableBoms << bom
      	end
      	return availableBoms
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

    end #End Class
  end #End module Extensions
end #End module Awestruct

module JBoss
   class Stacks
	  attr_reader  :availableBoms, :availableArchetypes, :availableRuntimes, :majorReleases, :minorReleases

	  def initialize(availableBoms, availableArchetypes, availableRuntimes, majorReleases, minorReleases)
		  @availableBoms = availableBoms
		  @availableArchetypes = availableArchetypes
		  @availableRuntimes = availableRuntimes
		  @majorReleases = majorReleases
		  @minorReleases = minorReleases
	  end
   end

   class Bom
	  attr_reader :name, :description, :groupId, :artifactId, :recommendedVersion, :availableVersions, :labels

	  def initialize(name, description, groupId, artifactId, recommendedVersion, availableVersions, labels)
		  @name = name
		  @description = description
		  @groupId = groupId
		  @artifactId = artifactId
		  @recommendedVersion = recommendedVersion
		  @availableVersions = availableVersions
		  @labels = labels
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


