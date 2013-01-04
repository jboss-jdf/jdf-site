module Awestruct
  module Extensions
    module Helper

      def include_file(filepath)
        file = File.open(filepath)
        contents = file.read
      end

      def include_remote_file(filepath)
        uri = URI(filepath)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
	      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
	      http.start 
	      request = Net::HTTP::Get.new(uri.request_uri)
        response = http.request(request)
        contents = response.body
      end
    end
  end
end
