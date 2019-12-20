module QRDA
  module Cat1
    class CommunicationPerformedImporter < SectionImporter
      def initialize(entry_finder = QRDA::Cat1::EntryFinder.new("./cda:entry/cda:act[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.156']"))
        super(entry_finder)
        @id_xpath = './cda:id'
        @code_xpath = "./cda:entryRelationship[@typeCode='REFR']/cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.88']/cda:value"
        @author_datetime_xpath = "./cda:author/cda:time"
        @sent_datetime_xpath = "./cda:effectiveTime/cda:low"
        @received_datetime_xpath = "./cda:effectiveTime/cda:high"
        @related_to_xpath = "./sdtc:inFulfillmentOf1/sdtc:actReference"
        @category_xpath = './cda:code'
        @medium_xpath = "./cda:participant[@typeCode='VIA']/cda:participantRole/cda:code"
        @entry_class = QDM::CommunicationPerformed
      end

      def create_entry(entry_element, nrh = NarrativeReferenceHandler.new)
        communication_performed = super
        communication_performed.category = code_if_present(entry_element.at_xpath(@category_xpath))
        communication_performed.medium = code_if_present(entry_element.at_xpath(@medium_xpath))
        communication_performed.sentDatetime = extract_time(entry_element, @sent_datetime_xpath)
        communication_performed.receivedDatetime = extract_time(entry_element, @received_datetime_xpath)
        communication_performed.sender = extract_entity(entry_element, "./cda:participant[@typeCode='AUT']")
        communication_performed.recipient = extract_entity(entry_element, "./cda:participant[@typeCode='IRCP']")
        # communication_performed.relatedTo = extract_related_to(entry_element)
        communication_performed
      end
    end
  end
  end