module QRDA
  module Cat1
    class ProviderCareExperienceImporter < SectionImporter
      def initialize(entry_finder = QRDA::Cat1::EntryFinder.new("./cda:entry/cda:observation[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.67']"))
        super(entry_finder)
        @id_xpath = './cda:id'
        @code_xpath = "./cda:value"
        @author_datetime_xpath = "./cda:author/cda:time"
        @entry_class = QDM::ProviderCareExperience
      end

      def create_entry(entry_element, nrh = NarrativeReferenceHandler.new)
        provider_care_experience = super
        provider_care_experience
      end

    end
  end
end