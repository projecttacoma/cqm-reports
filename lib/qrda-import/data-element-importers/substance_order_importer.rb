module QRDA
  module Cat1
    class SubstanceOrderImporter < SectionImporter
      def initialize(entry_finder = QRDA::Cat1::EntryFinder.new("./cda:entry/cda:substanceAdministration[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.47']"))
        super(entry_finder)
        @id_xpath = './cda:id'
        @code_xpath = "./cda:consumable/cda:manufacturedProduct/cda:manufacturedMaterial/cda:code"
        @author_datetime_xpath = "./cda:author/cda:time"
        @dosage_xpath = "./cda:doseQuantity"
        @supply_xpath = "./cda:entryRelationship/cda:supply[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.99']/cda:quantity"
        @frequency_xpath = "./cda:effectiveTime[@operator='A']/cda:period"
        @refills_xpath = "./cda:repeatNumber"
        @route_xpath = "./cda:routeCode"
        @reason_xpath = "./cda:entryRelationship[@typeCode='RSON']/cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.88']/cda:value"
        @entry_class = QDM::SubstanceOrder
      end

      def create_entry(entry_element, nrh = NarrativeReferenceHandler.new)
        substance_order = super
        substance_order.dosage = extract_scalar(entry_element, @dosage_xpath)
        substance_order.supply = extract_scalar(entry_element, @supply_xpath)
        substance_order.frequency = frequency_as_coded_value(entry_element, @frequency_xpath)
        substance_order.refills = extract_scalar(entry_element, @refills_xpath)&.value
        substance_order.route = code_if_present(entry_element.at_xpath(@route_xpath))
        substance_order.reason = extract_reason(entry_element)
        substance_order
      end

    end
  end
end