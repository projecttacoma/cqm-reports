module QRDA
  module Cat1
    class DiagnosisImporter < SectionImporter
      def initialize(entry_finder = QRDA::Cat1::EntryFinder.new("./cda:entry/cda:act[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.137']"))
        super(entry_finder)
        @id_xpath = './cda:entryRelationship/cda:observation/cda:id'
        @code_xpath = "./cda:entryRelationship/cda:observation[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.135']/cda:value"
        @author_datetime_xpath = "./cda:entryRelationship/cda:observation[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.135']/cda:author[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.155']/cda:time"
        @prevalence_period_xpath = "./cda:entryRelationship/cda:observation[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.135']/cda:effectiveTime"
        @anatomical_location_site_xpath = "./cda:entryRelationship/cda:observation[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.135']/cda:targetSiteCode"
        @severity_xpath = "./cda:entryRelationship/cda:observation[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.135']/cda:entryRelationship/cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.22.4.8']/cda:value"
        @entry_class = QDM::Diagnosis
      end

      def create_entry(entry_element, nrh = NarrativeReferenceHandler.new)
        diagnosis = super
        diagnosis.anatomicalLocationSite = code_if_present(entry_element.at_xpath(@anatomical_location_site_xpath))
        diagnosis.severity = code_if_present(entry_element.at_xpath(@severity_xpath))
        entity = extract_entity(entry_element, "./cda:entryRelationship/cda:observation//cda:participant[@typeCode='PRF']")
        diagnosis.recorder.concat(entity) if entity
        diagnosis
      end

    end
  end
end