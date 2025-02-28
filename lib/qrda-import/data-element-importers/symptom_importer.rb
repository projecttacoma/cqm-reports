module QRDA
  module Cat1
    class SymptomImporter < SectionImporter
      def initialize(entry_finder = QRDA::Cat1::EntryFinder.new("./cda:entry/cda:act[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.138']"))
        super(entry_finder)
        @id_xpath = "./cda:entryRelationship[@typeCode='SUBJ']/cda:observation/cda:id"
        @code_xpath = "./cda:entryRelationship[@typeCode='SUBJ']/cda:observation[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.136']/cda:value"
        @prevalence_period_xpath = "./cda:entryRelationship[@typeCode='SUBJ']/cda:observation[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.136']/cda:effectiveTime"
        @severity_xpath = "./cda:entryRelationship[@typeCode='SUBJ']/cda:observation[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.136']/cda:entryRelationship/cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.22.4.8']/cda:value"
        @entry_class = QDM::Symptom
      end

      def create_entry(entry_element, nrh = NarrativeReferenceHandler.new)
        symptom = super
        symptom.severity = code_if_present(entry_element.at_xpath(@severity_xpath))
        entity = extract_entity(entry_element, "./cda:entryRelationship/cda:observation[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.136']//cda:participant[@typeCode='PRF']")
        symptom.recorder.concat(entity) if entity
        symptom
      end

    end
  end
end