module QRDA
  module Cat1
    class MedicationDispensedImporter < MedicationImporter
      def initialize(entry_finder = QRDA::Cat1::EntryFinder.new("./cda:entry/cda:act[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.139']"))
        super(entry_finder)
        @relevant_period_xpath = "./cda:entryRelationship/cda:supply[cda:templateId/@root = '2.16.840.1.113883.10.20.22.4.18']/cda:effectiveTime"
        @author_datetime_xpath = "./cda:entryRelationship/cda:supply[cda:templateId/@root = '2.16.840.1.113883.10.20.22.4.18']/cda:author/cda:time"
        @code_xpath = "./cda:entryRelationship/cda:supply[cda:templateId/@root = '2.16.840.1.113883.10.20.22.4.18']/cda:product/cda:manufacturedProduct/cda:manufacturedMaterial/cda:code"
        @daysSupplied_xpath = ""
        @prescriberId_xpath = ""
        @dispenserId_xpath = ""
        @entry_class = QDM::MedicationDispensed
      end

      def create_entry(entry_element, nrh = NarrativeReferenceHandler.new)
        medication_dispensed = super
        medication_dispensed
      end

    end
  end
end