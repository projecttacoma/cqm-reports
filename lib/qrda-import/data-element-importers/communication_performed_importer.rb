module QRDA
    module Cat1
      class CommunicationPerformedImporter < SectionImporter
        def initialize(entry_finder = QRDA::Cat1::EntryFinder.new("./cda:entry/cda:act[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.156']"))
          super(entry_finder)
          @entry_does_not_have_reason = true
          @id_xpath = './cda:id'
          @code_xpath = "./cda:entryRelationship/cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.88']/cda:value"
          @author_datetime_xpath = "./cda:author/cda:time"
          @relevant_period_xpath = "./cda:effectiveTime"
          @related_to_xpath = "./sdtc:inFulfillmentOf1/sdtc:actReference"
          @category_xpath = './cda:code'
          @medium_xpath = "./cda:participant[@typeCode='VIA']/cda:participantRole/cda:code"
          @sender_xpath = "./cda:participant[@typeCode='AUT']/cda:participantRole/cda:code"
          @recipient_xpath = "./cda:participant[@typeCode='IRCP']/cda:participantRole/cda:code"
          @entry_class = QDM::CommunicationPerformed
        end
  
        def create_entry(entry_element, nrh = NarrativeReferenceHandler.new)
          communication_performed = super
          communication_performed.category = code_if_present(entry_element.at_xpath(@category_xpath))
          communication_performed.medium = code_if_present(entry_element.at_xpath(@medium_xpath))
          communication_performed.sender = code_if_present(entry_element.at_xpath(@sender_xpath))
          communication_performed.recipient = code_if_present(entry_element.at_xpath(@recipient_xpath))
          communication_performed.relatedTo = extract_related_to(entry_element)
          communication_performed
        end
      end
    end
  end