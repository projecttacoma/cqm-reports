module QRDA
  module Cat1
    class PhysicalExamRecommendedImporter < SectionImporter
      def initialize(entry_finder = QRDA::Cat1::EntryFinder.new("./cda:entry/cda:observation[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.60']"))
        super(entry_finder)
        @id_xpath = './cda:id'
        @code_xpath = "./cda:value"
        @author_datetime_xpath = "./cda:author/cda:time"
        @anatomical_location_site_xpath = "./cda:targetSiteCode"
        @reason_xpath = "./cda:entryRelationship[@typeCode='RSON']/cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.88']/cda:value"
        @entry_class = QDM::PhysicalExamRecommended
      end

      def create_entry(entry_element, nrh = NarrativeReferenceHandler.new)
        physical_exam_recommended = super
        physical_exam_recommended.anatomicalLocationSite = code_if_present(entry_element.at_xpath(@anatomical_location_site_xpath))
        extract_reason(entry_element, physical_exam_recommended)
        physical_exam_recommended
      end

    end
  end
end