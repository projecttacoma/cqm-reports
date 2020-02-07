module QRDA
  module Cat1
    class AssessmentPerformedImporter < SectionImporter
      def initialize(entry_finder = QRDA::Cat1::EntryFinder.new("./cda:entry/cda:observation[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.144']"))
        super(entry_finder)
        @id_xpath = './cda:id'
        @code_xpath = './cda:code'
        @author_datetime_xpath = "./cda:author/cda:time"
        @result_xpath = "./cda:value"
        @method_xpath = './cda:methodCode'
        @components_xpath = "./cda:entryRelationship/cda:observation[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.149']"
        @reason_xpath = "./cda:entryRelationship[@typeCode='RSON']/cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.88']/cda:value"
        @relevant_period_xpath = "./cda:effectiveTime"
        @relevant_date_time_xpath = './cda:effectiveTime[@value]'
        @entry_class = QDM::AssessmentPerformed
      end

      def create_entry(entry_element, nrh = NarrativeReferenceHandler.new)
        assessment_performed = super
        assessment_performed.method = code_if_present(entry_element.at_xpath(@method_xpath))
        assessment_performed.components = extract_components(entry_element)
        assessment_performed.reason = extract_reason(entry_element)
        assessment_performed.performer = extract_entity(entry_element, "./cda:participant[@typeCode='PRF']")
        assessment_performed
      end

    end
  end
end