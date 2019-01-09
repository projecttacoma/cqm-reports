module QRDA
  module Cat1
    class MedicationDischargeImporter < MedicationImporter
      def initialize(entry_finder = QRDA::Cat1::EntryFinder.new("./cda:entry/cda:act[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.105']"))
        super(entry_finder)
        @code_xpath = "./cda:entryRelationship/cda:substanceAdministration[cda:templateId/@root = '2.16.840.1.113883.10.20.22.4.16']/cda:consumable/cda:manufacturedProduct/cda:manufacturedMaterial/cda:code"
        @relevant_period_xpath = nil
        @author_datetime_xpath = "./cda:entryRelationship/cda:substanceAdministration[cda:templateId/@root = '2.16.840.1.113883.10.20.22.4.16']/cda:author/cda:time"
        @entry_class = QDM::MedicationDischarge
      end

      def create_entry(entry_element, nrh = NarrativeReferenceHandler.new)
        medication_discharge = super
        medication_discharge
      end

    end
  end
end