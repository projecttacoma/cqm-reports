module QRDA
  module Cat1
    class ImmunizationOrderImporter < SectionImporter
      def initialize(entry_finder = QRDA::Cat1::EntryFinder.new("./cda:entry/cda:substanceAdministration[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.143']"))
        super(entry_finder)
        @id_xpath = './cda:id'
        @code_xpath = "./cda:consumable/cda:manufacturedProduct/cda:manufacturedMaterial/cda:code"
        @active_datetime_xpath = "./cda:effectiveTime[@value]"
        @author_datetime_xpath = "./cda:author[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.155']/cda:time"
        @dosage_xpath = "./cda:doseQuantity"
        @supply_xpath = "./cda:entryRelationship/cda:supply[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.167']/cda:quantity"
        @route_xpath = "./cda:routeCode"
        @reason_xpath = "./cda:entryRelationship[@typeCode='RSON']/cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.88']/cda:value"
        @entry_class = QDM::ImmunizationOrder
      end

      def create_entry(entry_element, nrh = NarrativeReferenceHandler.new)
        immunization_order = super
        immunization_order.activeDatetime = extract_time(entry_element, @active_datetime_xpath)
        immunization_order.dosage = extract_scalar(entry_element, @dosage_xpath)
        immunization_order.supply = extract_scalar(entry_element, @supply_xpath)
        immunization_order.route = code_if_present(entry_element.at_xpath(@route_xpath))
        immunization_order.reason = extract_reason(entry_element)
        entity = extract_entity(entry_element, "./cda:participant[@typeCode='PRF']")
        immunization_order.requester.concat(entity) if entity
        immunization_order
      end

    end
  end
end