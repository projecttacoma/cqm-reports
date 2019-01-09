require_relative '../../test_helper'
require 'cqm/models'

module QRDA
  module Cat1
    class PatientRoundTripTest < MiniTest::Test
      include QRDA::Cat1

      def setup
        @importer = Cat1::PatientImporter.instance
        bd = 75.years.ago
        @patient = QDM::Patient.new(birthDatetime: bd, givenNames: %w['First Middle'], familyName: 'Family', bundleId: '1')
        @patient.extendedData = { 'medical_record_number' => '123', 'insurance_providers' => nil }
        @patient.dataElements << QDM::PatientCharacteristicBirthdate.new(birthDatetime: bd)
        @patient.dataElements << QDM::PatientCharacteristicRace.new(dataElementCodes: [QDM::Code.new('2106-3', 'Race & Ethnicity - CDC', 'White', '2.16.840.1.113883.6.238')])
        @patient.dataElements << QDM::PatientCharacteristicEthnicity.new(dataElementCodes: [QDM::Code.new('2186-5', 'Race & Ethnicity - CDC', 'Not Hispanic or Latino', '2.16.840.1.113883.6.238')])
        @patient.dataElements << QDM::PatientCharacteristicSex.new(dataElementCodes: [QDM::Code.new('M', 'Administrative sex (HL7)', 'Male', '2.16.840.1.113883.12.1')])
      end

      def create_test_measure
        mes = QDM::Measure.new
        mes.hqmf_id = 'b794a9c2-8e83-11e8-9eb6-529269fb1459'
        mes.hqmf_set_id = 'bdfa0e38-8e83-11e8-9eb6-529269fb1459'
        mes.description = 'Test Measure'
        mes.populations = [{"IPP" => "IPP"}]
        mes.elm = []
        mes.save
      end

      def generate_doc(patient)
        measures = QDM::Measure.all
        options = { start_time: Date.new(2012, 1, 1), end_time: Date.new(2012, 12, 31) }
        rawxml = Qrda1R5.new(patient, measures, options).render
        xml = Tempfile.new(['test_patient', '.xml'])
        xml.write rawxml
        xml.close
        doc = Nokogiri::XML(File.read(xml.path))
        doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
        doc.root.add_namespace_definition('sdtc', 'urn:hl7-org:sdtc')
        doc
      end

      def add_adverse_event(patient)
        @adverse_event_author_time = Time.new(2012, 1, 1, 4, 0, 0)
        @adverse_event_relevant_period = QDM::Interval.new(Time.new(2012, 1, 2, 4, 0, 0), Time.new(2012, 1, 2, 5, 0, 0))
        @adverse_event_codes = [QDM::Code.new('E08.311', 'ICD-10-CM'), QDM::Code.new('362.01', 'ICD-9-CM'), QDM::Code.new('4855003', 'SNOMED-CT')]
        patient.dataElements << QDM::AdverseEvent.new(authorDatetime: @adverse_event_author_time,
                                                      relevantPeriod: @adverse_event_relevant_period,
                                                      dataElementCodes: @adverse_event_codes)
      end

      def add_allergy_intolerance(patient)
        @allergy_intolerance_author_time = Time.new(2012, 1, 1, 4, 0, 0)
        @allergy_intolerance_prevalence_period = QDM::Interval.new(Time.new(2012, 1, 2, 4, 0, 0), Time.new(2012, 1, 2, 5, 0, 0))
        @allergy_intolerance_codes = [QDM::Code.new('E08.311', 'ICD-10-CM'), QDM::Code.new('362.01', 'ICD-9-CM'), QDM::Code.new('4855003', 'SNOMED-CT')]
        patient.dataElements << QDM::AllergyIntolerance.new(authorDatetime: @allergy_intolerance_author_time,
                                                            prevalencePeriod: @allergy_intolerance_prevalence_period,
                                                            dataElementCodes: @allergy_intolerance_codes)
      end

      def confirm_adverse_event(doc)
        assert_equal 1, doc.xpath("//cda:entry/cda:observation[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.146']").size
      end

      def confirm_allergy_intolerance(doc)
        assert_equal 1, doc.xpath("//cda:entry/cda:observation[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.147']").size
      end

      def compare_adverse_event(imported_patient)
        adverse_events = imported_patient.get_data_elements('adverse_event')
        assert_equal 1, adverse_events.size
        adverse_event = adverse_events[0]
        compare_time(@adverse_event_author_time, adverse_event.authorDatetime)
        compare_interval(@adverse_event_relevant_period, adverse_event.relevantPeriod)
        compare_codes(@adverse_event_codes, adverse_event.dataElementCodes)
      end

      def compare_allergy_intolerance(imported_patient)
        allergy_intolerances = imported_patient.get_data_elements('allergy', 'intolerance')
        assert_equal 1, allergy_intolerances.size
        allergy_intolerance = allergy_intolerances[0]
        compare_time(@allergy_intolerance_author_time, allergy_intolerance.authorDatetime)
        compare_interval(@allergy_intolerance_prevalence_period, allergy_intolerance.prevalencePeriod)
        compare_codes(@allergy_intolerance_codes, allergy_intolerance.dataElementCodes)
      end

      def test_patient_roundtrip
        add_adverse_event(@patient)
        add_allergy_intolerance(@patient)

        exported_qrda = generate_doc(@patient)

        confirm_adverse_event(exported_qrda)
        confirm_allergy_intolerance(exported_qrda)

        imported_patient = Cat1::PatientImporter.instance.parse_cat1(exported_qrda)

        compare_adverse_event(imported_patient) 
        compare_allergy_intolerance(imported_patient)       
      end

      def compare_time(exported_time, imported_time)
        assert_equal exported_time, imported_time
      end

      def compare_interval(exported_interval, imported_interval)
        assert_equal exported_interval.low, imported_interval.low
        assert_equal exported_interval.high, imported_interval.high
      end

      def compare_codes(exported_codes, imported_codes)
        assert_equal exported_codes.size, imported_codes.size
        exported_codes.each do |ec|
          assert imported_codes.collect { |ic| ic[:code] == ec.code && ic[:codeSystem] == ec.codeSystem }.include? true
        end
      end

      def compare_code(exported_code, imported_code)
        assert_equal exported_code.code = imported_code[:code]
        assert_equal exported_code.codeSystem = imported_code[:codeSystem]
      end
    end
  end
end