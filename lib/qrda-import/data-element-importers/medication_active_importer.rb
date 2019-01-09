module QRDA
  module Cat1
    class MedicationActiveImporter < MedicationImporter
      def initialize(entry_finder = QRDA::Cat1::EntryFinder.new("./cda:entry/cda:substanceAdministration[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.41']"))
        super(entry_finder)
        @author_datetime_xpath = nil
        @entry_class = QDM::MedicationActive
      end

      def create_entry(entry_element, nrh = NarrativeReferenceHandler.new)
        medication_active = super
        medication_active
      end

    end
  end
end