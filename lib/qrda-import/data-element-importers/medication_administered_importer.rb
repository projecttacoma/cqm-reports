module QRDA
  module Cat1
    class MedicationAdministeredImporter < MedicationImporter
      def initialize(entry_finder = QRDA::Cat1::EntryFinder.new("./cda:entry/cda:substanceAdministration[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.42']"))
        super(entry_finder)
        @route_xpath = "./cda:routeCode"
        @entry_class = QDM::MedicationAdministered
      end

      def create_entry(entry_element, nrh = NarrativeReferenceHandler.new)
        medication_administered = super
        medication_administered
      end

    end
  end
end