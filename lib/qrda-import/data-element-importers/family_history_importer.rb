module QRDA
  module Cat1
    class FamilyHistoryImporter < SectionImporter
      def initialize(entry_finder = QRDA::Cat1::EntryFinder.new("./cda:entry/cda:organizer[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.12']"))
        super(entry_finder)
        @id_xpath = './cda:id'
        @code_xpath = "./cda:component/cda:observation[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.112']/cda:value"
        @author_datetime_xpath = "./cda:component/cda:observation[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.112']/cda:author[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.155']/cda:time"
        @relationship_xpath = './cda:subject/cda:relatedSubject/cda:code'
        @entry_class = QDM::FamilyHistory
      end

      def create_entry(entry_element, nrh = NarrativeReferenceHandler.new)
        family_history = super
        family_history.relationship = code_if_present(entry_element.at_xpath(@relationship_xpath))
        family_history.recorder = extract_entity(entry_element, "./cda:component/cda:observation[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.112']//cda:participant[@typeCode='PRF']")
        family_history
      end

    end
  end
end