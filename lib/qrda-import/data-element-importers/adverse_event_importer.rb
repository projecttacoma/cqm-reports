module QRDA
  module Cat1
    class AdverseEventImporter < SectionImporter
      def initialize(entry_finder = QRDA::Cat1::EntryFinder.new("./cda:entry/cda:observation[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.146']"))
        super(entry_finder)
        @id_xpath = './cda:id'
        @code_xpath = './cda:entryRelationship/cda:observation/cda:value'
        @author_datetime_xpath = './cda:author/cda:time'
        @relevant_period_xpath = './cda:effectiveTime'
        @severity_xpath = "./cda:entryRelationship/cda:observation[cda:templateId/@root = '2.16.840.1.113883.10.20.22.4.8']/cda:value"
        @facility_locations_xpath = "./cda:participant[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.100']"
        @entry_class = QDM::AdverseEvent
      end

      def create_entry(entry_element, nrh = NarrativeReferenceHandler.new)
        adverse_event = super
        adverse_event.severity = code_if_present(entry_element.at_xpath(@severity_xpath))
        adverse_event.facilityLocation = extract_facility_locations(entry_element)[0]
        adverse_event
      end

    end
  end
end