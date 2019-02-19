module QRDA
  module Cat1
    class DeviceAppliedImporter < SectionImporter
      def initialize(entry_finder = QRDA::Cat1::EntryFinder.new("./cda:entry/cda:procedure[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.7']"))
        super(entry_finder)
        @id_xpath = './cda:id'
        @code_xpath = './cda:participant/cda:participantRole/cda:playingDevice/cda:code'
        @author_datetime_xpath = "./cda:author/cda:time"
        @relevant_period_xpath = "./cda:effectiveTime"
        @anatomical_location_site_xpath = "./cda:targetSiteCode"
        @entry_class = QDM::DeviceApplied
      end

      def create_entry(entry_element, nrh = NarrativeReferenceHandler.new)
        device_applied = super
        device_applied.anatomicalLocationSite = code_if_present(entry_element.at_xpath(@anatomical_location_site_xpath))
        device_applied
      end

    end
  end
end