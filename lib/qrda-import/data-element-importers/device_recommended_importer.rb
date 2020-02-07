module QRDA
  module Cat1
    class DeviceRecommendedImporter < SectionImporter
      def initialize(entry_finder = QRDA::Cat1::EntryFinder.new("./cda:entry/cda:act[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.131']"))
        super(entry_finder)
        @id_xpath = "./cda:entryRelationship/cda:supply[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.10']/cda:id"
        @code_xpath = "./cda:entryRelationship/cda:supply[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.10']/cda:participant/cda:participantRole/cda:playingDevice/cda:code"
        @author_datetime_xpath = "./cda:entryRelationship/cda:supply[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.10']/cda:author/cda:time"
        @reason_xpath = "./cda:entryRelationship/cda:supply[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.10']/cda:entryRelationship[@typeCode='RSON']/cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.88']/cda:value"
        @entry_class = QDM::DeviceRecommended
      end

      def create_entry(entry_element, nrh = NarrativeReferenceHandler.new)
        device_recommended = super
        device_recommended.reason = extract_reason(entry_element)
        device_recommended.requester = extract_entity(entry_element, "./cda:entryRelationship/cda:supply//cda:participant[@typeCode='PRF']")
        device_recommended
      end

    end
  end
end