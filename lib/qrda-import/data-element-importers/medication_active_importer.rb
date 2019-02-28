module QRDA
  module Cat1
    class MedicationActiveImporter < SectionImporter
      def initialize(entry_finder = QRDA::Cat1::EntryFinder.new("./cda:entry/cda:substanceAdministration[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.41']"))
        super(entry_finder)
        @id_xpath = './cda:id'
        @code_xpath = "./cda:consumable/cda:manufacturedProduct/cda:manufacturedMaterial/cda:code"
        @relevant_period_xpath = "./cda:effectiveTime"
        @dosage_xpath = "./cda:doseQuantity"
        @frequency_xpath = "./cda:effectiveTime[@operator='A']/cda:period"
        @route_xpath = "./cda:routeCode"
        @entry_class = QDM::MedicationActive
      end

      def create_entry(entry_element, nrh = NarrativeReferenceHandler.new)
        medication_active = super
        medication_active.dosage = extract_scalar(entry_element, @dosage_xpath)
        medication_active.frequency = frequency_as_coded_value(entry_element, @frequency_xpath)
        medication_active.route = code_if_present(entry_element.at_xpath(@route_xpath))
        medication_active
      end

    end
  end
end