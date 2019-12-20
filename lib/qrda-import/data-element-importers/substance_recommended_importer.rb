module QRDA
  module Cat1
    class SubstanceRecommendedImporter < SectionImporter
      def initialize(entry_finder = QRDA::Cat1::EntryFinder.new("./cda:entry/cda:substanceAdministration[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.75']"))
        super(entry_finder)
        @id_xpath = './cda:id'
        @code_xpath = "./cda:consumable/cda:manufacturedProduct/cda:manufacturedMaterial/cda:code"
        @author_datetime_xpath = "./cda:author/cda:time"
        @dosage_xpath = "./cda:doseQuantity"
        @frequency_xpath = "./cda:effectiveTime[@operator='A']/cda:period"
        @refills_xpath = "./cda:repeatNumber"
        @route_xpath = "./cda:routeCode"
        @reason_xpath = "./cda:entryRelationship[@typeCode='RSON']/cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.88']/cda:value"
        @entry_class = QDM::SubstanceRecommended
      end

      def create_entry(entry_element, nrh = NarrativeReferenceHandler.new)
        substance_recommended = super
        substance_recommended.dosage = extract_scalar(entry_element, @dosage_xpath)
        substance_recommended.frequency = frequency_as_coded_value(entry_element, @frequency_xpath)
        substance_recommended.refills = extract_scalar(entry_element, @refills_xpath)&.value
        substance_recommended.route = code_if_present(entry_element.at_xpath(@route_xpath))
        substance_recommended.reason = extract_reason(entry_element)
        substance_recommended.requester = extract_entity(entry_element, "./cda:participant[@typeCode='PRF']")
        substance_recommended
      end

    end
  end
end