module QRDA
  module Cat1
    class AdverseEventImporter < SectionImporter
      def initialize(entry_finder = QRDA::Cat1::EntryFinder.new("./cda:entry/cda:observation[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.146']"))
        super(entry_finder)
        @id_xpath = './cda:id'
        @code_xpath = "./cda:entryRelationship[@typeCode='CAUS']/cda:observation[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.148']/cda:value"
        @author_datetime_xpath = "./cda:author[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.155']/cda:time"
        @relevant_date_time_xpath = './cda:effectiveTime[@value]'
        @facility_locations_xpath = "./cda:participant[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.100']"
        @severity_xpath = "./cda:entryRelationship[@typeCode='REFR']/cda:observation[cda:templateId/@root = '2.16.840.1.113883.10.20.22.4.8']/cda:value"
        @type_xpath = "./cda:entryRelationship[@typeCode='MFST']/cda:observation[cda:templateId/@root = '2.16.840.1.113883.10.20.22.4.9']/cda:value"
        @entry_class = QDM::AdverseEvent
      end

      def create_entry(entry_element, nrh = NarrativeReferenceHandler.new)
        adverse_event = super
        adverse_event.severity = code_if_present(entry_element.at_xpath(@severity_xpath))
        adverse_event.type = code_if_present(entry_element.at_xpath(@type_xpath))
        adverse_event.facilityLocation = extract_facility_locations(entry_element)[0]
        entity = extract_entity(entry_element, "./cda:participant[@typeCode='PRF']")
        adverse_event.recorder.concat(entity) if entity
        adverse_event
      end

    end
  end
end