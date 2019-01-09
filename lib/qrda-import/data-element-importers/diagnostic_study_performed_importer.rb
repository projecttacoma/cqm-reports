module QRDA
  module Cat1
    class DiagnosticStudyPerformedImporter < SectionImporter
      def initialize(entry_finder = QRDA::Cat1::EntryFinder.new("./cda:entry/cda:observation[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.18']"))
        super(entry_finder)
        @id_xpath = './cda:id'
        @code_xpath = './cda:code'
        @relevant_period_xpath = "./cda:effectiveTime"
        @author_datetime_xpath = "./cda:author/cda:time"
        @result_xpath = "./cda:entryRelationship[@typeCode='REFR']/cda:observation/cda:value"
        @result_datetime_xpath = "./cda:entryRelationship[@typeCode='REFR']/cda:observation/cda:effectiveTime"
        @status_xpath = "./cda:entryRelationship/cda:observation[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.93']/cda:value"
        @method_xpath = './cda:methodCode'
        @facility_location_xpath = "./cda:participant[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.100']/cda:participantRole[@classCode='SDLOC']/cda:code"
        @components_xpath = "./cda:entryRelationship/cda:observation[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.149']"
        @entry_class = QDM::DiagnosticStudyPerformed
      end

      def create_entry(entry_element, nrh = NarrativeReferenceHandler.new)
        diagnostic_study_performed = super
        diagnostic_study_performed.resultDatetime = extract_time(entry_element, @result_datetime_xpath)
        diagnostic_study_performed.status = code_if_present(entry_element.at_xpath(@status_xpath))
        diagnostic_study_performed.method = code_if_present(entry_element.at_xpath(@method_xpath))
        diagnostic_study_performed.facilityLocation = code_if_present(entry_element.at_xpath(@facility_location_xpath))
        diagnostic_study_performed.components = extract_components(entry_element)
        diagnostic_study_performed
      end

    end
  end
end