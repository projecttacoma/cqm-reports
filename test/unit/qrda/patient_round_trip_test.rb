require_relative '../../test_helper'
require 'cqm/models'
require 'cqm_validators'
require 'nokogiri/diff'

module QRDA
  module Cat1
    class PatientRoundTripTest < MiniTest::Test
      include QRDA::Cat1

      def setup
        create_test_measures_collection
        @importer = Cat1::PatientImporter.instance
      end

      def create_test_measures_collection
        # Delete all existing for atomicity
        CQM::Measure.delete_all()
        mes = CQM::Measure.new
        mes.hqmf_id = 'b794a9c2-8e83-11e8-9eb6-529269fb1459'
        mes.hqmf_set_id = 'bdfa0e38-8e83-11e8-9eb6-529269fb1459'
        mes.description = 'Test Measure'
        mes.cql_libraries = []
        mes.save
      end

      def generate_doc(patient)
        measures = CQM::Measure.all
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

      def add_different_frequency_codes_to_medication(medication_test_patient)
        medication_test_element = medication_test_patient.qdmPatient.medications().first()

        institution_specified_range = medication_test_element.clone()
        institution_specified_range.frequency = QDM::Code.new('396107007', 'SNOMED-CT')
        medication_test_patient.qdmPatient.dataElements.push(institution_specified_range)

        institution_specified_point = medication_test_element.clone()
        institution_specified_point.frequency = QDM::Code.new('229797004', 'SNOMED-CT')
        medication_test_patient.qdmPatient.dataElements.push(institution_specified_point)

        institution_not_specified_range = medication_test_element.clone()
        institution_not_specified_range.frequency = QDM::Code.new('225752000', 'SNOMED-CT')
        medication_test_patient.qdmPatient.dataElements.push(institution_not_specified_range)

        institution_not_specified_point = medication_test_element.clone()
        institution_not_specified_point.frequency = QDM::Code.new('225756002', 'SNOMED-CT')
        medication_test_patient.qdmPatient.dataElements.push(institution_not_specified_point)
      end

      def test_exhaustive_patient_roundtrip
        puts "\n========================= QRDA ROUNDTRIP ========================="
        cqm_patients = QDM::PatientGeneration.generate_exhastive_data_element_patients(true)
        add_different_frequency_codes_to_medication(cqm_patients.find{|patient| patient.familyName.include? 'MedicationDispensed'})
        successful_count = 0
        cqm_patients.each do |cqm_patient| 
          datatype_name = cqm_patient.givenNames[0]
          # Initial QRDA export
          begin
            exported_qrda = generate_doc(cqm_patient)
          rescue StandardError => e
            puts "\e[31mError exporting QRDA for datatype #{datatype_name}: #{e.message}\e[0m"
          end
          # Import patient from QRDA
          begin
            imported_patient = @importer.parse_cat1(exported_qrda)
          rescue StandardError => e
            puts "\e[31mError importing QRDA for datatype #{datatype_name}: #{e.message}\e[0m"
          end
          # Re-export QRDA from imported patient
          begin
            # Roundtrip does not preserv extendedData
            imported_patient.qdmPatient.extendedData = cqm_patient.qdmPatient.extendedData      
            re_exported_qrda = generate_doc(imported_patient)
          rescue StandardError => e
            puts "\e[31mError Re-importing QRDA for datatype #{datatype_name}: #{e.message}\e[0m"
          end

          next unless (exported_qrda && re_exported_qrda)
          different = false
          differences = ''
          exported_qrda.diff(re_exported_qrda) do |change, change_info|
            # If change represents and addition or deletion
            if (change == "+" || change == "-")
              # Ignore guid and generation-time based changes
              if ((!change_info.parent.to_s.include? "effectiveTime") && (!change_info.parent.to_s.include? "extension=") && (!change_info.parent.to_s.include? "root=") &&
                (!((change_info.parent.name.include? "time") && ((change_info.parent.parent.name.include? "legalAuthenticator") || (change_info.parent.parent.name.include? "author")))))
                differences += "\e[31m#{change} #{change_info.to_html}\e[0m \n"
                different = true
              end
            end
          end
          if (!different)
            successful_count += 1
          else
            puts "\e[31mERROR: Roundtrip QRDA Differences For Datatype #{datatype_name}\e[0m \n"
            puts differences
          end
        end

        assert_equal cqm_patients.count, successful_count
      end

      def test_exhaustive_qrda_validation
        puts "\n========================= QRDA VALIDATION ========================="
        cqm_patients = QDM::PatientGeneration.generate_exhastive_data_element_patients(true)
        add_different_frequency_codes_to_medication(cqm_patients.find{|patient| patient.familyName.include? 'MedicationDispensed'})
        validator = CqmValidators::Cat1R51.instance
        cda_validator = CqmValidators::CDA.instance
        successful_count = 0
        cqm_patients.each do |cqm_patient|
          datatype_name = cqm_patient.givenNames[0]
          begin
            exported_qrda = generate_doc(cqm_patient)
            errors = validator.validate(exported_qrda)
            cda_errors = cda_validator.validate(exported_qrda)
            if (errors.count.zero? && cda_errors.count.zero?)
              successful_count += 1
            end
            errors.each do |error|
              puts "\e[31mQRDA Schematron Error In #{datatype_name}: #{error.message}\e[0m"
            end
            cda_errors.each do |error|
              puts "\e[31mCDA Schema Error In #{datatype_name}: #{error.message}\e[0m"
            end
          rescue StandardError => e
            puts "\e[31mException validating #{datatype_name}: #{e.message}\e[0m"
          end
        end
        assert_equal cqm_patients.count, successful_count
      end
    end
  end
end