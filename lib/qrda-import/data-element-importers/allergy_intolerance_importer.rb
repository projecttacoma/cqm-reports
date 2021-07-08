module QRDA
  module Cat1
    class AllergyIntoleranceImporter < SectionImporter
      def initialize(entry_finder = QRDA::Cat1::EntryFinder.new("./cda:entry/cda:observation[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.147']"))
        super(entry_finder)
        @id_xpath = './cda:id'
        @code_xpath = "./cda:participant[@typeCode='CSM']/cda:participantRole/cda:playingEntity/cda:code"
        @author_datetime_xpath = "./cda:author/cda:time"
        @prevalence_period_xpath = "./cda:effectiveTime"
        @severity_xpath = "./cda:entryRelationship/cda:observation[cda:templateId/@root = '2.16.840.1.113883.10.20.22.4.8']/cda:value"
        @type_xpath = "./cda:entryRelationship/cda:observation[cda:templateId/@root = '2.16.840.1.113883.10.20.22.4.9']/cda:value"
        @entry_class = QDM::AllergyIntolerance
      end

      def create_entry(entry_element, nrh = NarrativeReferenceHandler.new)
        allergy_intolerance = super
        allergy_intolerance.severity = code_if_present(entry_element.at_xpath(@severity_xpath))
        allergy_intolerance.type = code_if_present(entry_element.at_xpath(@type_xpath))
        entity = extract_entity(entry_element, "./cda:participant[@typeCode='PRF']")
        allergy_intolerance.recorder.concat(entity) if entity
        allergy_intolerance
      end

    end
  end
end