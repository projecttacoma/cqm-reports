module QRDA
    module Cat1
      class CommunicationPerformedImporter < SectionImporter
        def initialize(entry_finder = QRDA::Cat1::EntryFinder.new("./cda:entry/cda:act[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.4']"))
          super(entry_finder)
          @id_xpath = './cda:id'
          @code_xpath = './cda:code'
          @author_datetime_xpath = "./cda:author/cda:time"
          @related_to_xpath = "./sdtc:inFulfillmentOf1/sdtc:actReference"
          @category_xpath = ""
          @medium_xpath = ""
          @sender_xpath = ""
          @recipient_xpath = "" 
          @entry_class = QDM::CommunicationPerformed
        end
  
        def create_entry(entry_element, nrh = NarrativeReferenceHandler.new)
          communication_performed = super
          communication_performed.relatedTo = extract_related_to(entry_element)
          communication_performed
        end
  
      end
    end
  end