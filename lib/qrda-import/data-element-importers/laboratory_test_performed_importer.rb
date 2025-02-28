module QRDA
  module Cat1
    class LaboratoryTestPerformedImporter < SectionImporter
      def initialize(entry_finder = QRDA::Cat1::EntryFinder.new("./cda:entry/cda:observation[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.38']"))
        super(entry_finder)
        @id_xpath = './cda:id'
        @code_xpath = './cda:code'
        @relevant_period_xpath = "./cda:effectiveTime"
        @relevant_date_time_xpath = './cda:effectiveTime[@value]'
        @author_datetime_xpath = "./cda:author[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.155']/cda:time"
        @status_xpath = "./cda:entryRelationship/cda:observation[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.93']/cda:value"
        @method_xpath = './cda:methodCode'
        @result_xpath = "./cda:entryRelationship[@typeCode='REFR']/cda:observation[cda:templateId/@root = '2.16.840.1.113883.10.20.22.4.2']/cda:value"
        @result_datetime_xpath = "./cda:entryRelationship[@typeCode='REFR']/cda:observation/cda:effectiveTime"
        @components_xpath = "./cda:entryRelationship[@typeCode='REFR']/cda:observation[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.149']"
        @reason_xpath = "./cda:entryRelationship[@typeCode='RSON']/cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.88']/cda:value"
        @related_to_xpath = "./sdtc:inFulfillmentOf1/sdtc:actReference"
        @entry_class = QDM::LaboratoryTestPerformed
      end

      def create_entry(entry_element, nrh = NarrativeReferenceHandler.new)
        laboratory_test_performed = super
        laboratory_test_performed.status = code_if_present(entry_element.at_xpath(@status_xpath))
        laboratory_test_performed.method = code_if_present(entry_element.at_xpath(@method_xpath))
        laboratory_test_performed.resultDatetime = extract_time(entry_element, @result_datetime_xpath)
        laboratory_test_performed.components = extract_components(entry_element)
        laboratory_test_performed.reason = extract_reason(entry_element)
        entity = extract_entity(entry_element, "./cda:participant[@typeCode='PRF']")
        laboratory_test_performed.performer.concat(entity) if entity
        laboratory_test_performed.relatedTo = extract_related_to(entry_element)
        laboratory_test_performed
      end

    end
  end
end