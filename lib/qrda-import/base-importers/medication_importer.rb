module QRDA
  module Cat1
    class MedicationImporter < SectionImporter
  
      def initialize(entry_finder = nil)
        super(entry_finder)
        @id_xpath = './cda:id'
        @code_xpath = "./cda:consumable/cda:manufacturedProduct/cda:manufacturedMaterial/cda:code"
        @relevant_period_xpath = "./cda:effectiveTime"
        @author_datetime_xpath = "./cda:author/cda:time"
        @dosage_xpath = "./cda:doseQuantity"
        @route_xpath = "./cda:routeCode"
      end

      def create_entry(entry_element, nrh = NarrativeReferenceHandler.new)
        medication = super
        medication.dosage = extract_scalar(entry_element, @dosage_xpath)
        medication.route = code_if_present(entry_element.at_xpath(@route_xpath))
        medication
      end
    end
  end
end
