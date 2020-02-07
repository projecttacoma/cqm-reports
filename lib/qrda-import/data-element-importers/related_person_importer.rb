module QRDA
  module Cat1
    class RelatedPersonImporter < SectionImporter
      def initialize(entry_finder = QRDA::Cat1::EntryFinder.new("./cda:entry/cda:observation[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.170']"))
        super(entry_finder)
        @id_xpath = './cda:id'
        @code_xpath = "./cda:value"
        @entry_class = QDM::RelatedPerson
      end

      def create_entry(entry_element, nrh = NarrativeReferenceHandler.new)
        related_person = super
        related_person.identifier = extract_id(entry_element, './cda:participant/cda:participantRole/cda:id')
        related_person
      end

    end
  end
end