module QRDA
  module Cat1
    class DiagnosticStudyOrderImporter < SectionImporter
      def initialize(entry_finder = QRDA::Cat1::EntryFinder.new("./cda:entry/cda:observation[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.17']"))
        super(entry_finder)
        @id_xpath = './cda:id'
        @code_xpath = './cda:code'
        @author_datetime_xpath = "./cda:author/cda:time"
        @reason_xpath = "./cda:entryRelationship[@typeCode='RSON']/cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.88']/cda:value"
        @entry_class = QDM::DiagnosticStudyOrder
      end

      def create_entry(entry_element, nrh = NarrativeReferenceHandler.new)
        diagnostic_study_order = super
        extract_reason(entry_element, diagnostic_study_order)
        diagnostic_study_order
      end

    end
  end
end