module QRDA
  module Cat1
    class InterventionPerformedImporter < SectionImporter
      def initialize(entry_finder = QRDA::Cat1::EntryFinder.new("./cda:entry/cda:act[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.32']"))
        super(entry_finder)
        @id_xpath = './cda:id'
        @code_xpath = './cda:code'
        @relevant_period_xpath = "./cda:effectiveTime"
        @relevant_date_time_xpath = './cda:effectiveTime'
        @author_datetime_xpath = "./cda:author[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.155']/cda:time"
        @result_xpath = "./cda:entryRelationship/cda:observation[cda:templateId/@root = '2.16.840.1.113883.10.20.22.4.2']/cda:value"
        @status_xpath = "./cda:entryRelationship/cda:observation[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.93']/cda:value"
        @reason_xpath = "./cda:entryRelationship[@typeCode='RSON']/cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.88']/cda:value"
        @related_to_xpath = "./sdtc:inFulfillmentOf1/sdtc:actReference"
        @entry_class = QDM::InterventionPerformed
      end

      def create_entry(entry_element, nrh = NarrativeReferenceHandler.new)
        intervention_performed = super
        intervention_performed.status = code_if_present(entry_element.at_xpath(@status_xpath))
        intervention_performed.reason = extract_reason(entry_element)
        intervention_performed.performer = extract_entity(entry_element, "./cda:participant[@typeCode='PRF']")
        intervention_performed.relatedTo = extract_related_to(entry_element)
        intervention_performed
      end

    end
  end
end