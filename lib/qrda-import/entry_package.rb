module QRDA
  module Cat1
    class EntryPackage

      attr_accessor :importer_type

      def initialize(type)
        self.importer_type = type
      end  

      def package_entries(doc, nrh)
        importer_type.create_entries(doc, nrh)
      end
    end
  end
end
