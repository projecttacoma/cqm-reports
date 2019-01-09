module QRDA
  module Cat1
    class SubstanceAdministeredImporter < MedicationAdministeredImporter
      def initialize(entry_finder = QRDA::Cat1::EntryFinder.new("./cda:entry/cda:substanceAdministration[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.42']"))
        super(entry_finder)
        @entry_class = QDM::SubstanceAdministered
      end

      def create_entry(entry_element, nrh = NarrativeReferenceHandler.new)
        substance_administered = super
        substance_administered
      end

    end
  end
end