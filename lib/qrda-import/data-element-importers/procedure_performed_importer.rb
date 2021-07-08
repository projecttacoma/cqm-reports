module QRDA
  module Cat1
    class ProcedurePerformedImporter < SectionImporter
      def initialize(entry_finder = QRDA::Cat1::EntryFinder.new("./cda:entry/cda:procedure[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.64']"))
        super(entry_finder)
        @id_xpath = './cda:id'
        @code_xpath = "./cda:code"
        @relevant_period_xpath = "./cda:effectiveTime"
        @relevant_date_time_xpath = './cda:effectiveTime'
        @author_datetime_xpath = "./cda:author/cda:time"
        @method_xpath = './cda:methodCode'
        @result_xpath = "./cda:entryRelationship/cda:observation[cda:templateId/@root = '2.16.840.1.113883.10.20.22.4.2']/cda:value"
        @status_xpath = "./cda:entryRelationship/cda:observation[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.93']/cda:value"
        @anatomical_location_site_xpath = "./cda:targetSiteCode"
        @incision_datetime_xpath = "./cda:entryRelationship/cda:procedure[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.89']/cda:effectiveTime"
        @components_xpath = "./cda:entryRelationship/cda:observation[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.149']"
        @reason_xpath = "./cda:entryRelationship[@typeCode='RSON']/cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.88']/cda:value"
        @rank_xpath = "./cda:entryRelationship/cda:observation[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.166']/cda:value/@value"
        @entry_class = QDM::ProcedurePerformed
      end

      def create_entry(entry_element, nrh = NarrativeReferenceHandler.new)
        procedure_performed = super
        procedure_performed.method = code_if_present(entry_element.at_xpath(@method_xpath))
        procedure_performed.status = code_if_present(entry_element.at_xpath(@status_xpath))
        procedure_performed.anatomicalLocationSite = code_if_present(entry_element.at_xpath(@anatomical_location_site_xpath))
        procedure_performed.incisionDatetime = extract_time(entry_element, @incision_datetime_xpath)
        procedure_performed.components = extract_components(entry_element)
        procedure_performed.reason = extract_reason(entry_element)
        entity = extract_entity(entry_element, "./cda:participant[@typeCode='PRF']")
        procedure_performed.performer.concat(entity) if entity
        procedure_performed.rank = entry_element.at_xpath(@rank_xpath)&.value&.strip.to_i if entry_element.at_xpath(@rank_xpath)&.value
        procedure_performed
      end

    end
  end
end