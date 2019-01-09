module QRDA
  module Cat1
    class CommunicationFromProviderToPatientImporter < SectionImporter
      def initialize(entry_finder = QRDA::Cat1::EntryFinder.new("./cda:entry/cda:act[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.3']"))
        super(entry_finder)
        @id_xpath = './cda:id'
        @code_xpath = './cda:code'
        @author_datetime_xpath = "./cda:author/cda:time"
        @entry_class = QDM::CommunicationFromProviderToPatient
      end

      def create_entry(entry_element, nrh = NarrativeReferenceHandler.new)
        communication_from_provider_to_patient = super
        communication_from_provider_to_patient
      end

    end
  end
end