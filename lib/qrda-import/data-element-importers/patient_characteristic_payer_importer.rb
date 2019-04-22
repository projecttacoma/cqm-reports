module QRDA
  module Cat1
    class PatientCharacteristicPayerImporter < SectionImporter
      def initialize(entry_finder = QRDA::Cat1::EntryFinder.new("./cda:entry/cda:observation[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.55']"))
        super(entry_finder)
        @id_xpath = './cda:id'
        @code_xpath = './cda:value'
        @relevant_period_xpath = './cda:effectiveTime'
        @entry_class = QDM::PatientCharacteristicPayer
      end

      def create_entry(entry_element, nrh = NarrativeReferenceHandler.new)
        patient_characteristic_payer = super
        patient_characteristic_payer
      end

    end
  end
end