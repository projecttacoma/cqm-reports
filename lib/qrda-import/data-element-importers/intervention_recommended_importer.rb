module QRDA
  module Cat1
    class InterventionRecommendedImporter < SectionImporter
      def initialize(entry_finder = QRDA::Cat1::EntryFinder.new("./cda:entry/cda:act[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.33']"))
        super(entry_finder)
        @id_xpath = './cda:id'
        @code_xpath = './cda:code'
        @author_datetime_xpath = "./cda:author/cda:time"
        @reason_xpath = "./cda:entryRelationship[@typeCode='RSON']/cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.88']/cda:value"
        @entry_class = QDM::InterventionRecommended
      end

      def create_entry(entry_element, nrh = NarrativeReferenceHandler.new)
        intervention_recommended = super
        intervention_recommended.reason = extract_reason(entry_element)
        intervention_recommended.requester = extract_entity(entry_element, "./cda:participant[@typeCode='PRF']")
        intervention_recommended
      end

    end
  end
end