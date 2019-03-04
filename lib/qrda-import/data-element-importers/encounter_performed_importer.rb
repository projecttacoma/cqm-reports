module QRDA
  module Cat1
    class EncounterPerformedImporter < SectionImporter
      def initialize(entry_finder = QRDA::Cat1::EntryFinder.new("./cda:entry/cda:act[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.133']"))
        super(entry_finder)
        @id_xpath = './cda:entryRelationship/cda:encounter/cda:id'
        @code_xpath = "./cda:entryRelationship/cda:encounter[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.23']/cda:code"
        @relevant_period_xpath = "./cda:entryRelationship/cda:encounter[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.23']/cda:effectiveTime"
        @author_datetime_xpath = "./cda:entryRelationship/cda:encounter[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.23']/cda:author/cda:time"
        @admission_source_xpath = "./cda:entryRelationship/cda:encounter[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.23']/cda:participant/cda:participantRole[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.151']/cda:code"
        @discharge_disposition_xpath = "./cda:entryRelationship/cda:encounter[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.23']/sdtc:dischargeDispositionCode"
        @facility_xpath = "./cda:entryRelationship/cda:encounter/cda:participant[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.100']"
        @principal_diagnosis_xpath = "./cda:entryRelationship/cda:encounter[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.23']/cda:entryRelationship/cda:observation[cda:code/@code='8319008']/cda:value"
        @diagnosis_xpath = "./cda:entryRelationship/cda:encounter[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.23']/cda:entryRelationship/cda:act/cda:entryRelationship/cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.22.4.4']"
        @entry_class = QDM::EncounterPerformed
      end

      def create_entry(entry_element, nrh = NarrativeReferenceHandler.new)
        encounter_performed = super
        encounter_performed.admissionSource = code_if_present(entry_element.at_xpath(@admission_source_xpath))
        encounter_performed.dischargeDisposition = code_if_present(entry_element.at_xpath(@discharge_disposition_xpath))
        encounter_performed.facilityLocations = extract_facility_locations(entry_element)
        encounter_performed.principalDiagnosis = code_if_present(entry_element.at_xpath(@principal_diagnosis_xpath))
        encounter_performed.diagnoses = extract_diagnoses(entry_element)
        if encounter_performed&.relevantPeriod&.low && encounter_performed&.relevantPeriod&.high
          los = encounter_performed.relevantPeriod.high - encounter_performed.relevantPeriod.low
          encounter_performed.lengthOfStay = QDM::Quantity.new(los.to_i, 'd')
        end
        encounter_performed
      end

      private

      def extract_diagnoses(parent_element)
        diagnosis_elements = parent_element.xpath(@diagnosis_xpath)
        diagnosis_list = []
        diagnosis_elements.each do |diagnosis_element|
          diagnosis_value = diagnosis_element.at_xpath("./cda:value")
          diagnosis_list << code_if_present(diagnosis_value)
        end
        diagnosis_list.empty? ? nil : diagnosis_list
      end

    end
  end
end