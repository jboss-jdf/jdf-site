module Awestruct
  module Extensions
    module Helper
      def include_file(filepath)
        file = File.open(filepath)
        contents = file.read
      end
    end
  end
end
