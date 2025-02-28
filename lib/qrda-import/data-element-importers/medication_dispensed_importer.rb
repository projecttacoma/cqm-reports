module QRDA
  module Cat1
    class MedicationDispensedImporter < SectionImporter
      def initialize(entry_finder = QRDA::Cat1::EntryFinder.new("./cda:entry/cda:act[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.139']"))
        super(entry_finder)
        @id_xpath = "./cda:entryRelationship[@typeCode='SUBJ']/cda:supply/cda:id"
        @code_xpath = "./cda:entryRelationship[@typeCode='SUBJ']/cda:supply[cda:templateId/@root = '2.16.840.1.113883.10.20.22.4.18']/cda:product/cda:manufacturedProduct/cda:manufacturedMaterial/cda:code"
        @relevant_period_xpath = "./cda:entryRelationship[@typeCode='SUBJ']/cda:supply[cda:templateId/@root = '2.16.840.1.113883.10.20.22.4.18']/cda:effectiveTime"
        @relevant_date_time_xpath = "./cda:entryRelationship[@typeCode='SUBJ']/cda:supply[cda:templateId/@root = '2.16.840.1.113883.10.20.22.4.18']/cda:effectiveTime"
        @author_datetime_xpath = "./cda:entryRelationship[@typeCode='SUBJ']/cda:supply[cda:templateId/@root = '2.16.840.1.113883.10.20.22.4.18']/cda:author[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.155']/cda:time"
        @refills_xpath = "./cda:entryRelationship[@typeCode='SUBJ']/cda:supply[cda:templateId/@root = '2.16.840.1.113883.10.20.22.4.18']/cda:entryRelationship[@typeCode='REFR']/cda:substanceAdministration/cda:repeatNumber"
        @dosage_xpath = "./cda:entryRelationship[@typeCode='SUBJ']/cda:supply[cda:templateId/@root = '2.16.840.1.113883.10.20.22.4.18']/cda:entryRelationship[@typeCode='REFR']/cda:substanceAdministration/cda:doseQuantity"
        @supply_xpath = "./cda:entryRelationship[@typeCode='SUBJ']/cda:supply[cda:templateId/@root = '2.16.840.1.113883.10.20.22.4.18']/cda:entryRelationship[@typeCode='COMP']/cda:supply[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.99']/cda:quantity"
        @frequency_xpath = "./cda:entryRelationship[@typeCode='SUBJ']/cda:supply[cda:templateId/@root = '2.16.840.1.113883.10.20.22.4.18']/cda:entryRelationship[@typeCode='REFR']/cda:substanceAdministration/cda:effectiveTime[@operator='A']/cda:period"
        @days_supplied_xpath = "./cda:entryRelationship[@typeCode='SUBJ']/cda:supply[cda:templateId/@root = '2.16.840.1.113883.10.20.22.4.18']/cda:entryRelationship[@typeCode='REFR']/cda:supply[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.157']/cda:quantity"
        @route_xpath = "./cda:entryRelationship[@typeCode='SUBJ']/cda:supply[cda:templateId/@root = '2.16.840.1.113883.10.20.22.4.18']/cda:entryRelationship[@typeCode='REFR']/cda:substanceAdministration/cda:routeCode"
        @entry_class = QDM::MedicationDispensed
      end

      def create_entry(entry_element, nrh = NarrativeReferenceHandler.new)
        medication_dispensed = super
        medication_dispensed.refills = extract_refills(entry_element, @refills_xpath)
        medication_dispensed.dosage = extract_scalar(entry_element, @dosage_xpath)
        medication_dispensed.supply = extract_scalar(entry_element, @supply_xpath)
        medication_dispensed.frequency = frequency_as_coded_value(entry_element, @frequency_xpath)
        medication_dispensed.daysSupplied = extract_scalar(entry_element, @days_supplied_xpath)&.value
        medication_dispensed.route = code_if_present(entry_element.at_xpath(@route_xpath))
        entity1 = extract_entity(entry_element, "./cda:entryRelationship[@typeCode='SUBJ']/cda:supply[cda:templateId/@root = '2.16.840.1.113883.10.20.22.4.18']//cda:participant[@typeCode='PRF']")
        medication_dispensed.prescriber.concat(entity1) if entity1
        entity2 = extract_entity(entry_element, "./cda:entryRelationship[@typeCode='SUBJ']/cda:supply[cda:templateId/@root = '2.16.840.1.113883.10.20.22.4.18']/cda:participant[@typeCode='DIST']")
        medication_dispensed.dispenser.concat(entity2) if entity2
        medication_dispensed
      end

    end
  end
end