module QRDA
  module Cat1
    class CommunicationFromPatientToProviderImporter < SectionImporter
      def initialize(entry_finder = QRDA::Cat1::EntryFinder.new("./cda:entry/cda:act[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.2']"))
        super(entry_finder)
        @id_xpath = './cda:id'
        @code_xpath = './cda:code'
        @author_datetime_xpath = "./cda:author/cda:time"
        @entry_class = QDM::CommunicationFromPatientToProvider
      end

      def create_entry(entry_element, nrh = NarrativeReferenceHandler.new)
        communication_from_patient_to_provider = super
        communication_from_patient_to_provider
      end

    end
  end
end