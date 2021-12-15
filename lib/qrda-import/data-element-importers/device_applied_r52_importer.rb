module QRDA
  module Cat1
    class DeviceAppliedR52Importer < SectionImporter
      def initialize(entry_finder = QRDA::Cat1::EntryFinder.new("./cda:entry/cda:procedure[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.7']"))
        super(entry_finder)
        @id_xpath = './cda:id'
        @code_xpath = './cda:participant/cda:participantRole/cda:playingDevice/cda:code'
        @author_datetime_xpath = "./cda:author[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.155']/cda:time"
        @relevant_period_xpath = "./cda:effectiveTime"
        @relevant_date_time_xpath = './cda:effectiveTime[@value]'
        @anatomical_location_site_xpath = "./cda:targetSiteCode"
        @reason_xpath = "./cda:entryRelationship[@typeCode='RSON']/cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.88']/cda:value"
        @entry_class = QDM::DeviceApplied
      end

      def create_entry(entry_element, nrh = NarrativeReferenceHandler.new)
        device_applied = super
        device_applied.anatomicalLocationSite = code_if_present(entry_element.at_xpath(@anatomical_location_site_xpath))
        device_applied.reason = extract_reason(entry_element)
        entity = extract_entity(entry_element, "./cda:participant[@typeCode='PRF']")
        device_applied.performer.concat(entity) if entity
        device_applied
      end

    end
  end
end