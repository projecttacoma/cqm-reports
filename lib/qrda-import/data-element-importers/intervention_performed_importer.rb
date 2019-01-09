module QRDA
  module Cat1
    class InterventionPerformedImporter < SectionImporter
      def initialize(entry_finder = QRDA::Cat1::EntryFinder.new("./cda:entry/cda:act[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.32']"))
        super(entry_finder)
        @id_xpath = './cda:id'
        @code_xpath = './cda:code'
        @relevant_period_xpath = "./cda:effectiveTime"
        @author_datetime_xpath = "./cda:author/cda:time"
        @result_xpath = "./cda:entryRelationship[@typeCode='REFR']/cda:observation/cda:value"
        @status_xpath = "./cda:entryRelationship/cda:observation[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.93']/cda:value"
        @entry_class = QDM::InterventionPerformed
      end

      def create_entry(entry_element, nrh = NarrativeReferenceHandler.new)
        intervention_performed = super
        intervention_performed.status = code_if_present(entry_element.at_xpath(@status_xpath))
        intervention_performed
      end

    end
  end
end