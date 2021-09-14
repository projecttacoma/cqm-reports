module QRDA
  module Cat1
    class MedicationAdministeredImporter < SectionImporter
      def initialize(entry_finder = QRDA::Cat1::EntryFinder.new("./cda:entry/cda:substanceAdministration[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.42']"))
        super(entry_finder)
        @id_xpath = './cda:id'
        @code_xpath = "./cda:consumable/cda:manufacturedProduct/cda:manufacturedMaterial/cda:code"
        @author_datetime_xpath = "./cda:author[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.155']/cda:time"
        @relevant_period_xpath = "./cda:effectiveTime"
        @relevant_date_time_xpath = './cda:effectiveTime'
        @dosage_xpath = "./cda:doseQuantity"
        @frequency_xpath = "./cda:effectiveTime[@operator='A']/cda:period"
        @route_xpath = "./cda:routeCode"
        @reason_xpath = "./cda:entryRelationship[@typeCode='RSON']/cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.88']/cda:value"
        @entry_class = QDM::MedicationAdministered
      end

      def create_entry(entry_element, nrh = NarrativeReferenceHandler.new)
        medication_administered = super
        medication_administered.dosage = extract_scalar(entry_element, @dosage_xpath)
        medication_administered.frequency = frequency_as_coded_value(entry_element, @frequency_xpath)
        medication_administered.route = code_if_present(entry_element.at_xpath(@route_xpath))
        medication_administered.reason = extract_reason(entry_element)
        medication_administered.performer = extract_entity(entry_element, "./cda:participant[@typeCode='PRF']")
        medication_administered
      end

    end
  end
end