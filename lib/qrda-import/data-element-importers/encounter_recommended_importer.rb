module QRDA
  module Cat1
    class EncounterRecommendedImporter < SectionImporter
      def initialize(entry_finder = QRDA::Cat1::EntryFinder.new("./cda:entry/cda:act[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.134']"))
        super(entry_finder)
        @id_xpath = './cda:id'
        @code_xpath = "./cda:entryRelationship/cda:encounter[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.24']/cda:code"
        @author_datetime_xpath = "./cda:entryRelationship/cda:encounter[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.24']/cda:author/cda:time"
        @facility_xpath = "./cda:entryRelationship/cda:encounter[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.24']/cda:participant[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.100']"
        @entry_class = QDM::EncounterRecommended
      end

      def create_entry(entry_element, nrh = NarrativeReferenceHandler.new)
        encounter_recommended = super
        encounter_recommended.facilityLocation = extract_facility(entry_element)
        encounter_recommended
      end

    end
  end
end