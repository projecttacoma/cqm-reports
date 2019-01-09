module QRDA
  module Cat1
    class EncounterOrderImporter < SectionImporter
      def initialize(entry_finder = QRDA::Cat1::EntryFinder.new("./cda:entry/cda:act[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.132']"))
        super(entry_finder)
        @id_xpath = './cda:entryRelationship/cda:encounter/cda:id'
        @code_xpath = "./cda:entryRelationship/cda:encounter[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.22']/cda:code"
        @author_datetime_xpath = "./cda:entryRelationship/cda:encounter[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.22']/cda:author/cda:time"
        @facility_location_xpath = "./cda:entryRelationship/cda:encounter[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.22']/cda:participant[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.100']/cda:participantRole[@classCode='SDLOC']/cda:code"
        @entry_class = QDM::EncounterOrder
      end

      def create_entry(entry_element, nrh = NarrativeReferenceHandler.new)
        encounter_order = super
        encounter_order.facilityLocation = code_if_present(entry_element.at_xpath(@facility_location_xpath))
        encounter_order
      end

    end
  end
end