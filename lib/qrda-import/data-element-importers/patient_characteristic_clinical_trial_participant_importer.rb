module QRDA
  module Cat1
    class PatientCharacteristicClinicalTrialParticipantImporter < SectionImporter
      def initialize(entry_finder = QRDA::Cat1::EntryFinder.new("./cda:entry/cda:observation[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.51']"))
        super(entry_finder)
        @id_xpath = './cda:id'
        @code_xpath = './cda:value'
        @relevant_period_xpath = "./cda:effectiveTime"
        @reason_xpath = "./cda:entryRelationship[@typeCode='RSON']/cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.88']/cda:value"
        @entry_class = QDM::PatientCharacteristicClinicalTrialParticipant
      end

      def create_entry(entry_element, nrh = NarrativeReferenceHandler.new)
        patient_characteristic_clinical_trial_participant = super
        patient_characteristic_clinical_trial_participant.reason = extract_reason(entry_element)
        patient_characteristic_clinical_trial_participant
      end

    end
  end
end