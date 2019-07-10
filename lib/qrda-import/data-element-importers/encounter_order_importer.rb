module QRDA
  module Cat1
    class EncounterOrderImporter < SectionImporter
      def initialize(entry_finder = QRDA::Cat1::EntryFinder.new("./cda:entry/cda:act[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.132']"))
        super(entry_finder)
        @id_xpath = './cda:entryRelationship/cda:encounter/cda:id'
        @code_xpath = "./cda:entryRelationship/cda:encounter[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.22']/cda:code"
        @author_datetime_xpath = "./cda:entryRelationship/cda:encounter[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.22']/cda:author/cda:time"
        @facility_locations_xpath = "./cda:entryRelationship/cda:encounter[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.22']/cda:participant[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.100']"
        @reason_xpath = "./cda:entryRelationship/cda:encounter[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.22']/cda:entryRelationship[@typeCode='RSON']/cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.88']/cda:value"
        @entry_class = QDM::EncounterOrder
      end

      def create_entry(entry_element, nrh = NarrativeReferenceHandler.new)
        encounter_order = super
        encounter_order.facilityLocation = extract_facility_locations(entry_element)[0]
        encounter_order.reason = extract_reason(entry_element)
        encounter_order
      end

    end
  end
end