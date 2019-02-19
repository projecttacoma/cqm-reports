module QRDA
    module Cat1
      class AssessmentOrderImporter < SectionImporter
        def initialize(entry_finder = QRDA::Cat1::EntryFinder.new("./cda:entry/cda:observation[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.17']"))
          super(entry_finder)
          @id_xpath = './cda:id'
          @code_xpath = './cda:code'
          @author_datetime_xpath = "./cda:author/cda:time"
          @method_xpath = './cda:methodCode'
          @entry_class = QDM::DiagnosticStudyOrder
        end
  
        def create_entry(entry_element, nrh = NarrativeReferenceHandler.new)
          diagnostic_study_order = super
          diagnostic_study_order.method = code_if_present(entry_element.at_xpath(@method_xpath))
          diagnostic_study_order
        end
  
      end
    end
  end