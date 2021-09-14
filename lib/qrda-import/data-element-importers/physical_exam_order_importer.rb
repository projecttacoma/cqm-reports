module QRDA
  module Cat1
    class PhysicalExamOrderImporter < SectionImporter
      def initialize(entry_finder = QRDA::Cat1::EntryFinder.new("./cda:entry/cda:observation[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.58']"))
        super(entry_finder)
        @id_xpath = './cda:id'
        @code_xpath = "./cda:value"
        @author_datetime_xpath = "./cda:author[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.155']/cda:time"
        @anatomical_location_site_xpath = "./cda:targetSiteCode"
        @reason_xpath = "./cda:entryRelationship[@typeCode='RSON']/cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.88']/cda:value"
        @entry_class = QDM::PhysicalExamOrder
      end

      def create_entry(entry_element, nrh = NarrativeReferenceHandler.new)
        physical_exam_order = super
        physical_exam_order.anatomicalLocationSite = code_if_present(entry_element.at_xpath(@anatomical_location_site_xpath))
        physical_exam_order.reason = extract_reason(entry_element)
        physical_exam_order.requester = extract_entity(entry_element, "./cda:participant[@typeCode='PRF']")
        physical_exam_order
      end

    end
  end
end