module QRDA
  module Cat1
    class PhysicalExamPerformedImporter < SectionImporter
      def initialize(entry_finder = QRDA::Cat1::EntryFinder.new("./cda:entry/cda:observation[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.59']"))
        super(entry_finder)
        @id_xpath = './cda:id'
        @code_xpath = "./cda:code"
        @relevant_period_xpath = "./cda:effectiveTime"
        @relevant_date_time_xpath = './cda:effectiveTime'
        @author_datetime_xpath = "./cda:author[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.155']/cda:time"
        @method_xpath = './cda:methodCode'
        @result_xpath = "./cda:value"
        @anatomical_location_site_xpath = "./cda:targetSiteCode"
        @components_xpath = "./cda:entryRelationship[@typeCode='REFR']/cda:observation[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.149']"
        @reason_xpath = "./cda:entryRelationship[@typeCode='RSON']/cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.88']/cda:value"
        @related_to_xpath = "./sdtc:inFulfillmentOf1/sdtc:actReference"
        @entry_class = QDM::PhysicalExamPerformed
      end

      def create_entry(entry_element, nrh = NarrativeReferenceHandler.new)
        physical_exam_performed = super
        physical_exam_performed.method = code_if_present(entry_element.at_xpath(@method_xpath))
        physical_exam_performed.anatomicalLocationSite = code_if_present(entry_element.at_xpath(@anatomical_location_site_xpath))
        physical_exam_performed.components = extract_components(entry_element)
        physical_exam_performed.reason = extract_reason(entry_element)
        entity = extract_entity(entry_element, "./cda:participant[@typeCode='PRF']")
        physical_exam_performed.performer.concat(entity) if entity
        physical_exam_performed.relatedTo = extract_related_to(entry_element)
        physical_exam_performed
      end

    end
  end
end