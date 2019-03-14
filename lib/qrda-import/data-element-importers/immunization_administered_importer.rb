module QRDA
  module Cat1
    class ImmunizationAdministeredImporter < SectionImporter
      def initialize(entry_finder = QRDA::Cat1::EntryFinder.new("./cda:entry/cda:substanceAdministration[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.140']"))
        super(entry_finder)
        @id_xpath = './cda:id'
        @code_xpath = "./cda:consumable/cda:manufacturedProduct/cda:manufacturedMaterial/cda:code"
        @author_datetime_xpath = "./cda:effectiveTime"
        @dosage_xpath = "./cda:doseQuantity"
        @route_xpath = "./cda:routeCode"
        @entry_class = QDM::ImmunizationAdministered
      end

      def create_entry(entry_element, nrh = NarrativeReferenceHandler.new)
        immunization_administered = super
        immunization_administered.dosage = extract_scalar(entry_element, @dosage_xpath)
        immunization_administered.route = code_if_present(entry_element.at_xpath(@route_xpath))
        immunization_administered
      end

    end
  end
end