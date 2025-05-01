module QRDA
  module Cat1
    class EncounterRecommendedImporter < SectionImporter
      def initialize(entry_finder = QRDA::Cat1::EntryFinder.new("./cda:entry/cda:act[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.134']"))
        super(entry_finder)
        @id_xpath = "./cda:entryRelationship[@typeCode='SUBJ']/cda:encounter/cda:id"
        @code_xpath = "./cda:entryRelationship[@typeCode='SUBJ']/cda:encounter[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.24']/cda:code"
        @author_datetime_xpath = "./cda:entryRelationship[@typeCode='SUBJ']/cda:encounter[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.24']/cda:author[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.155']/cda:time"
        @facility_locations_xpath = "./cda:entryRelationship[@typeCode='SUBJ']/cda:encounter[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.24']/cda:participant[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.100']"
        @reason_xpath = "./cda:entryRelationship[@typeCode='SUBJ']/cda:encounter[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.24']/cda:entryRelationship[@typeCode='RSON']/cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.88']/cda:value"
        @entry_class = QDM::EncounterRecommended
      end

      def create_entry(entry_element, nrh = NarrativeReferenceHandler.new)
        encounter_recommended = super
        encounter_recommended.facilityLocation = extract_facility_locations(entry_element)[0]
        encounter_recommended.reason = extract_reason(entry_element)
        entity = extract_entity(entry_element, "./cda:entryRelationship[@typeCode='SUBJ']/cda:encounter//cda:participant[@typeCode='PRF']")
        encounter_recommended.requester.concat(entity) if entity
        encounter_recommended
      end

    end
  end
end