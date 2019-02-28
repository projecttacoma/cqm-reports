module QRDA
  module Cat1
    class PatientCharacteristicExpiredImporter < SectionImporter
      def initialize(entry_finder = QRDA::Cat1::EntryFinder.new("./cda:entry/cda:observation[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.54']"))
        super(entry_finder)
        @id_xpath = './cda:id'
        @code_xpath = './cda:value'
        @expired_datetime_xpath = './cda:effectiveTime/cda:low'
        @cause = "./cda:entryRelationship/cda:observation[cda:templateId/@root = '2.16.840.1.113883.10.20.22.4.4']/cda:value"
        @entry_class = QDM::PatientCharacteristicExpired
      end

      def create_entry(entry_element, nrh = NarrativeReferenceHandler.new)
        patient_characteristic_expired = super
        patient_characteristic_expired.expiredDatetime = extract_time(entry_element, @expired_datetime_xpath)
        patient_characteristic_expired.cause = code_if_present(entry_element.at_xpath(@cause))
        patient_characteristic_expired
      end

    end
  end
end