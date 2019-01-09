module QRDA
  module Cat1
    class ProcedureOrderImporter < SectionImporter
      def initialize(entry_finder = QRDA::Cat1::EntryFinder.new("./cda:entry/cda:procedure[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.63']"))
        super(entry_finder)
        @id_xpath = './cda:id'
        @code_xpath = './cda:code'
        @author_datetime_xpath = "./cda:author/cda:time"
        @method_xpath = './cda:methodCode'
        @anatomical_approach_site_xpath = "./cda:approachSiteCode"
        @anatomical_location_site_xpath = "./cda:targetSiteCode"
        @ordinality_xpath = "./cda:priorityCode"
        @entry_class = QDM::ProcedureOrder
      end

      def create_entry(entry_element, nrh = NarrativeReferenceHandler.new)
        procedure_order = super
        procedure_order.method = code_if_present(entry_element.at_xpath(@method_xpath))
        procedure_order.anatomicalApproachSite = code_if_present(entry_element.at_xpath(@anatomical_approach_site_xpath))
        procedure_order.anatomicalLocationSite = code_if_present(entry_element.at_xpath(@anatomical_location_site_xpath))
        procedure_order.ordinality = code_if_present(entry_element.at_xpath(@ordinality_xpath))
        procedure_order
      end

    end
  end
end