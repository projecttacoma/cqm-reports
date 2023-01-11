module QRDA
  module Cat1
    class EncounterPerformedImporter < SectionImporter
      def initialize(entry_finder = QRDA::Cat1::EntryFinder.new("./cda:entry/cda:encounter[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.23']"))
        super(entry_finder)
        @id_xpath = './cda:id'
        @code_xpath = "./cda:code"
        @relevant_period_xpath = "./cda:effectiveTime"
        @author_datetime_xpath = "./cda:author[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.155']/cda:time"
        @admission_source_xpath = "./cda:participant/cda:participantRole[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.151']/cda:code"
        @discharge_disposition_xpath = "./sdtc:dischargeDispositionCode"
        @facility_locations_xpath = "./cda:participant[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.100']"
        @clazz_xpath = "./cda:entryRelationship/cda:act[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.171']/cda:code"
        @diagnosis_xpath = "./cda:entryRelationship/cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.168']"
        @related_to_xpath = "./sdtc:inFulfillmentOf1/sdtc:actReference"
        @entry_class = QDM::EncounterPerformed
      end

      def create_entry(entry_element, nrh = NarrativeReferenceHandler.new)
        encounter_performed = super
        encounter_performed.admissionSource = code_if_present(entry_element.at_xpath(@admission_source_xpath))
        encounter_performed.dischargeDisposition = code_if_present(entry_element.at_xpath(@discharge_disposition_xpath))
        encounter_performed.facilityLocations = extract_facility_locations(entry_element)
        encounter_performed.clazz = code_if_present(entry_element.at_xpath(@clazz_xpath))
        encounter_performed.diagnoses = extract_diagnoses(entry_element)
        if encounter_performed&.relevantPeriod&.low && encounter_performed&.relevantPeriod&.high
          los = encounter_performed.relevantPeriod.high.to_date - encounter_performed.relevantPeriod.low.to_date
          encounter_performed.lengthOfStay = QDM::Quantity.new(los.to_i, 'd')
        end
        entity = extract_entity(entry_element, "./cda:participant[@typeCode='PRF']")
        encounter_performed.participant.concat(entity) if entity
        extract_modifier_code(encounter_performed, entry_element)
        encounter_performed.relatedTo = extract_related_to(entry_element)
        encounter_performed
      end

      private

      def extract_modifier_code(encounter_performed, entry_element)
        code_element = entry_element.at_xpath(@code_xpath)
        return unless code_element

        qualifier_name = code_element.at_xpath('./cda:qualifier/cda:name')
        qualifier_value = code_element.at_xpath('./cda:qualifier/cda:value')
        codes_modifiers[encounter_performed.id] = { name: code_if_present(qualifier_name), value: code_if_present(qualifier_value), xpath_location: entry_element.path } if qualifier_value || qualifier_name
      end

      def extract_diagnoses(parent_element)
        diagnosis_elements = parent_element.xpath(@diagnosis_xpath)
        diagnosis_list = []
        diagnosis_elements.each do |diagnosis_element|
          diagnosis_component = QDM::DiagnosisComponent.new
          diagnosis_component.code = code_if_present(diagnosis_element.at_xpath('./cda:value'))
          diagnosis_component.presentOnAdmissionIndicator = code_if_present(diagnosis_element.at_xpath("./cda:entryRelationship/cda:observation[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.169']/cda:value"))
          diagnosis_component.rank = diagnosis_element.at_xpath("./cda:entryRelationship/cda:observation[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.166']/cda:value/@value")&.value&.strip.to_i
          diagnosis_list << diagnosis_component
        end
        diagnosis_list.empty? ? nil : diagnosis_list
      end

    end
  end
end