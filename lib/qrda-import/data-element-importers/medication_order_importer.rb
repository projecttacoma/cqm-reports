module QRDA
  module Cat1
    class MedicationOrderImporter < SectionImporter
      def initialize(entry_finder = QRDA::Cat1::EntryFinder.new("./cda:entry/cda:substanceAdministration[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.47']"))
        super(entry_finder)
        @id_xpath = './cda:id'
        @code_xpath = "./cda:consumable/cda:manufacturedProduct/cda:manufacturedMaterial/cda:code"
        @relevant_period_xpath = "./cda:effectiveTime"
        @author_datetime_xpath = "./cda:author[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.155']/cda:time"
        @dosage_xpath = "./cda:doseQuantity"
        @supply_xpath = "./cda:entryRelationship/cda:supply[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.99']/cda:quantity"
        @frequency_xpath = "./cda:effectiveTime[@operator='A']/cda:period"
        @refills_xpath = "./cda:repeatNumber"
        @route_xpath = "./cda:routeCode"
        @setting_xpath = "./cda:participant[@typeCode='LOC']/cda:participantRole/cda:code"
        @prescriber_id_xpath = "./cda:author/cda:assignedAuthor/cda:id"
        @days_supplied_xpath = "./cda:entryRelationship/cda:supply[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.157']/cda:quantity"
        @reason_xpath = "./cda:entryRelationship[@typeCode='RSON']/cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.88']/cda:value"
        @related_to_xpath = "./sdtc:inFulfillmentOf1/sdtc:actReference"
        @entry_class = QDM::MedicationOrder
      end

      def create_entry(entry_element, nrh = NarrativeReferenceHandler.new)
        medication_order = super
        medication_order.dosage = extract_scalar(entry_element, @dosage_xpath)
        medication_order.supply = extract_scalar(entry_element, @supply_xpath)
        medication_order.frequency = frequency_as_coded_value(entry_element, @frequency_xpath)
        medication_order.refills = extract_refills(entry_element, @refills_xpath)
        medication_order.route = code_if_present(entry_element.at_xpath(@route_xpath))
        medication_order.setting = code_if_present(entry_element.at_xpath(@setting_xpath))
        medication_order.daysSupplied = extract_scalar(entry_element, @days_supplied_xpath)&.value
        medication_order.reason = extract_reason(entry_element)
        entity = extract_entity(entry_element, "./cda:participant[@typeCode='PRF']")
        medication_order.prescriber.concat(entity) if entity
        medication_order.relatedTo = extract_related_to(entry_element)
        medication_order
      end

    end
  end
end