module QRDA
  module Cat1
    class MedicationDischargeImporter < SectionImporter
      def initialize(entry_finder = QRDA::Cat1::EntryFinder.new("./cda:entry/cda:act[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.105']"))
        super(entry_finder)
        @id_xpath = './cda:id'
        @code_xpath = "./cda:entryRelationship/cda:substanceAdministration[cda:templateId/@root = '2.16.840.1.113883.10.20.22.4.16']/cda:consumable/cda:manufacturedProduct/cda:manufacturedMaterial/cda:code"
        @author_datetime_xpath = "./cda:entryRelationship/cda:substanceAdministration[cda:templateId/@root = '2.16.840.1.113883.10.20.22.4.16']/cda:author/cda:time"
        @refills_xpath = "./cda:entryRelationship/cda:substanceAdministration[cda:templateId/@root = '2.16.840.1.113883.10.20.22.4.16']/cda:repeatNumber"
        @dosage_xpath = "./cda:entryRelationship/cda:substanceAdministration[cda:templateId/@root = '2.16.840.1.113883.10.20.22.4.16']/cda:doseQuantity"
        @supply_xpath = "./cda:entryRelationship/cda:supply[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.99']/cda:quantity"
        @frequency_xpath = "./cda:entryRelationship/cda:substanceAdministration[cda:templateId/@root = '2.16.840.1.113883.10.20.22.4.16']/cda:effectiveTime[@operator='A']/cda:period"
        @days_supplied_xpath = "./cda:entryRelationship/cda:supply[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.157']/cda:quantity"
        @route_xpath = "./cda:entryRelationship/cda:substanceAdministration[cda:templateId/@root = '2.16.840.1.113883.10.20.22.4.16']/cda:routeCode"

        @entry_class = QDM::MedicationDischarge
      end

      def create_entry(entry_element, nrh = NarrativeReferenceHandler.new)
        medication_discharge = super
        medication_discharge.refills = extract_scalar(entry_element, @refills_xpath)&.value
        medication_discharge.dosage = extract_scalar(entry_element, @dosage_xpath)
        medication_discharge.supply = extract_scalar(entry_element, @supply_xpath)
        medication_discharge.frequency = frequency_as_coded_value(entry_element, @frequency_xpath)
        medication_discharge.daysSupplied = extract_scalar(entry_element, @days_supplied_xpath)&.value
        medication_discharge.route = code_if_present(entry_element.at_xpath(@route_xpath))
        medication_discharge
      end

    end
  end
end