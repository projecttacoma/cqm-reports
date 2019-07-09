module QRDA
  module Cat1
    class ProcedureRecommendedImporter < SectionImporter
      def initialize(entry_finder = QRDA::Cat1::EntryFinder.new("./cda:entry/cda:procedure[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.65']"))
        super(entry_finder)
        @id_xpath = './cda:id'
        @code_xpath = "./cda:code"
        @author_datetime_xpath = "./cda:author/cda:time"
        @anatomical_location_site_xpath = "./cda:targetSiteCode"
        @ordinality_xpath = "./cda:priorityCode"
        @reason_xpath = "./cda:entryRelationship[@typeCode='RSON']/cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.88']/cda:value"
        @entry_class = QDM::ProcedureRecommended
      end

      def create_entry(entry_element, nrh = NarrativeReferenceHandler.new)
        procedure_recommended = super
        procedure_recommended.anatomicalLocationSite = code_if_present(entry_element.at_xpath(@anatomical_location_site_xpath))
        procedure_recommended.ordinality = code_if_present(entry_element.at_xpath(@ordinality_xpath))
        extract_reason(entry_element, procedure_recommended)
        procedure_recommended
      end

    end
  end
end