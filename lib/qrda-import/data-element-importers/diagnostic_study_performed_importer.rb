module QRDA
  module Cat1
    class DiagnosticStudyPerformedImporter < SectionImporter
      def initialize(entry_finder = QRDA::Cat1::EntryFinder.new("./cda:entry/cda:observation[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.18']"))
        super(entry_finder)
        @id_xpath = './cda:id'
        @code_xpath = './cda:code'
        @relevant_period_xpath = "./cda:effectiveTime"
        @author_datetime_xpath = "./cda:author/cda:time"
        @result_xpath = "./cda:entryRelationship/cda:observation[cda:templateId/@root = '2.16.840.1.113883.10.20.22.4.2']/cda:value"
        @result_datetime_xpath = "./cda:entryRelationship/cda:observation[cda:templateId/@root = '2.16.840.1.113883.10.20.22.4.2']/cda:effectiveTime"
        @status_xpath = "./cda:entryRelationship/cda:observation[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.93']/cda:value"
        @method_xpath = './cda:methodCode'
        @facility_locations_xpath = "./cda:participant[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.100']"
        @components_xpath = "./cda:entryRelationship/cda:observation[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.149']"
        @reason_xpath = "./cda:entryRelationship[@typeCode='RSON']/cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.88']/cda:value"
        @entry_class = QDM::DiagnosticStudyPerformed
      end

      def create_entry(entry_element, nrh = NarrativeReferenceHandler.new)
        diagnostic_study_performed = super
        diagnostic_study_performed.resultDatetime = extract_time(entry_element, @result_datetime_xpath)
        diagnostic_study_performed.resultDatetime ||= extract_interval(entry_element, @result_datetime_xpath).low
        diagnostic_study_performed.status = code_if_present(entry_element.at_xpath(@status_xpath))
        diagnostic_study_performed.method = code_if_present(entry_element.at_xpath(@method_xpath))
        diagnostic_study_performed.facilityLocation = extract_facility_locations(entry_element)[0]
        diagnostic_study_performed.components = extract_components(entry_element)
        extract_reason(entry_element, diagnostic_study_performed)
        diagnostic_study_performed
      end

    end
  end
end