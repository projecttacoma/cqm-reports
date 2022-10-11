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
        address = CQM::Address.new(
          use: 'HP',
          street: ['202 Burlington Rd.'],
          city: 'Bedford',
          state: 'MA',
          zip: '01730',
          country: 'US'
        )
        telecom = CQM::Telecom.new(
          use: 'HP',
          value: '555-555-2003'
        )
        @options = { start_time: Date.new(2012, 1, 1), end_time: Date.new(2012, 12, 31), patient_addresses: [address], patient_telecoms: [telecom] }
      end

      def create_test_measures_collection
        # Delete all existing for atomicity
        CQM::Measure.delete_all
        mes = CQM::Measure.new
        mes.hqmf_id = 'b794a9c2-8e83-11e8-9eb6-529269fb1459'
        mes.hqmf_set_id = 'bdfa0e38-8e83-11e8-9eb6-529269fb1459'
        mes.description = 'Test Measure'
        mes.cql_libraries = []
        mes.save
      end

      def generate_doc(patient, options = nil)
        measures = CQM::Measure.all
        options ||= @options
        rawxml = Qrda1R5.new(patient, measures, options).render
        xml = Tempfile.new(['test_patient', '.xml'])
        xml.write rawxml
        xml.close
        doc = Nokogiri::XML(File.read(xml.path))
        doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
        doc.root.add_namespace_definition('sdtc', 'urn:hl7-org:sdtc')
        doc
      end

      def generate_shell_patient(type)
        cqm_patient = QDM::BaseTypeGeneration.generate_cqm_patient(type)
        qdm_patient = QDM::BaseTypeGeneration.generate_qdm_patient
        # Add patient characteristics
        sex = QDM::PatientGeneration.generate_loaded_datatype('QDM::PatientCharacteristicSex')
        race = QDM::PatientGeneration.generate_loaded_datatype('QDM::PatientCharacteristicRace')
        ethnicity = QDM::PatientGeneration.generate_loaded_datatype('QDM::PatientCharacteristicEthnicity')
        birthdate = QDM::PatientGeneration.generate_loaded_datatype('QDM::PatientCharacteristicBirthdate')
        payer = QDM::PatientGeneration.generate_loaded_datatype('QDM::PatientCharacteristicPayer')
        qdm_patient.dataElements.push(sex)
        qdm_patient.dataElements.push(race)
        qdm_patient.dataElements.push(ethnicity)
        qdm_patient.dataElements.push(birthdate)
        qdm_patient.dataElements.push(payer)
        cqm_patient.qdmPatient = qdm_patient
        cqm_patient
      end

      def test_interval_round_trips
        cqm_patient = generate_shell_patient('interval')
        cqm_patient.qdmPatient.dataElements << QDM::EncounterPerformed.new(relevantPeriod: QDM::Interval.new(nil, nil),
                                                                           dataElementCodes: [QDM::BaseTypeGeneration.generate_code_field])
        cqm_patient.qdmPatient.dataElements << QDM::ProcedurePerformed.new(relevantPeriod: QDM::Interval.new(Time.now, nil),
                                                                           dataElementCodes: [QDM::BaseTypeGeneration.generate_code_field])
        cqm_patient.qdmPatient.dataElements << QDM::InterventionPerformed.new(relevantPeriod: QDM::Interval.new(Time.now, Time.now),
                                                                              dataElementCodes: [QDM::BaseTypeGeneration.generate_code_field])
        cqm_patient.qdmPatient.dataElements << QDM::AssessmentPerformed.new(relevantPeriod: QDM::Interval.new(nil, Time.now),
                                                                            dataElementCodes: [QDM::BaseTypeGeneration.generate_code_field])
        doc = generate_doc(cqm_patient, @options)
        imported_patient, _warnings = @importer.parse_cat1(doc)
        # Both high and low values are nil
        assert_equal nil, imported_patient.qdmPatient.encounters.first.relevantPeriod.low
        assert_equal nil, imported_patient.qdmPatient.encounters.first.relevantPeriod.high
        # Only high value is nil
        assert imported_patient.qdmPatient.procedures.first.relevantPeriod.low.is_a? DateTime
        assert_equal nil, imported_patient.qdmPatient.procedures.first.relevantPeriod.high
        # Both low and high have a DateTime value
        assert imported_patient.qdmPatient.interventions.first.relevantPeriod.low.is_a? DateTime
        assert imported_patient.qdmPatient.interventions.first.relevantPeriod.high.is_a? DateTime
        # Only low value is nil
        assert_equal nil, imported_patient.qdmPatient.assessments.first.relevantPeriod.low
        assert imported_patient.qdmPatient.assessments.first.relevantPeriod.high.is_a? DateTime
      end

      def add_different_frequency_codes_to_medication(medication_test_patient)
        medication_test_element = medication_test_patient.qdmPatient.medications.first

        institution_specified_range = medication_test_element.clone
        institution_specified_range.frequency = QDM::Code.new('396107007', '2.16.840.1.113883.6.96')
        medication_test_patient.qdmPatient.dataElements.push(institution_specified_range)

        institution_specified_point = medication_test_element.clone
        institution_specified_point.frequency = QDM::Code.new('229797004', '2.16.840.1.113883.6.96')
        medication_test_patient.qdmPatient.dataElements.push(institution_specified_point)

        institution_not_specified_range = medication_test_element.clone
        institution_not_specified_range.frequency = QDM::Code.new('225752000', '2.16.840.1.113883.6.96')
        medication_test_patient.qdmPatient.dataElements.push(institution_not_specified_range)

        institution_not_specified_point = medication_test_element.clone
        institution_not_specified_point.frequency = QDM::Code.new('225756002', '2.16.840.1.113883.6.96')
        medication_test_patient.qdmPatient.dataElements.push(institution_not_specified_point)
      end

      def generate_provider
        provider = CQM::Provider.new(
          givenNames: ['Joe'],
          familyName: 'Smith',
          specialty: '282N00000A',
          title: 'Dr.'
        )
        address = CQM::Address.new(
          street: ['Street'],
          city: 'City',
          state: 'state',
          zip: 'zip',
          country: 'country',
          use: 'use'
        )
        telecom = CQM::Telecom.new(
          preferred: true,
          value: 'value',
          use: 'use'
        )
        npi = QDM::Identifier.new(namingSystem: CQM::Provider::NPI_OID, value: '1693839684')
        tin = QDM::Identifier.new(namingSystem: CQM::Provider::TAX_ID_OID, value: '538782414')
        ccn = QDM::Identifier.new(namingSystem: CQM::Provider::CCN_OID, value: '159826')
        provider.ids << npi
        provider.ids << tin
        provider.ids << ccn
        provider.addresses << address
        provider.telecoms << telecom
        provider
      end

      def test_negated_vs
        cqm_patient = generate_shell_patient('negated_vs')
        qdm_patient = QDM::Patient.new
        dt = QDM::PatientGeneration.generate_loaded_datatype('QDM::EncounterOrder', true)
        dt.dataElementCodes = [QDM::Code.new('1.2.3.4', '1.2.3.4.5.6.7.8.9.10')]
        qdm_patient.dataElements << dt
        cqm_patient.qdmPatient = qdm_patient
        doc = generate_doc(cqm_patient, @options)
        assert_equal 1, doc.xpath('//cda:code[@nullFlavor="NA" and @sdtc:valueSet="1.2.3.4"]').size
      end

      def test_provider_roundtrip
        cqm_patient = generate_shell_patient('provider')
        provider = generate_provider
        options = @options.merge(provider: provider)
        doc = generate_doc(cqm_patient, options)
        assert_equal provider.specialty, doc.at_xpath('cda:ClinicalDocument/cda:documentationOf/cda:serviceEvent/cda:performer/cda:assignedEntity/cda:code/@code').value
        assert_equal provider.familyName, doc.at_xpath('cda:ClinicalDocument/cda:documentationOf/cda:serviceEvent/cda:performer/cda:assignedEntity/cda:assignedPerson/cda:name/cda:family').text
        assert_equal provider.givenNames.join(' '), doc.at_xpath('cda:ClinicalDocument/cda:documentationOf/cda:serviceEvent/cda:performer/cda:assignedEntity/cda:assignedPerson/cda:name/cda:given').text
        assert_equal provider.addresses.first.street.join(' '), doc.at_xpath('cda:ClinicalDocument/cda:documentationOf/cda:serviceEvent/cda:performer/cda:assignedEntity/cda:addr/cda:streetAddressLine').text
        assert_equal provider.addresses.first.city, doc.at_xpath('cda:ClinicalDocument/cda:documentationOf/cda:serviceEvent/cda:performer/cda:assignedEntity/cda:addr/cda:city').text
        assert_equal provider.addresses.first.state, doc.at_xpath('cda:ClinicalDocument/cda:documentationOf/cda:serviceEvent/cda:performer/cda:assignedEntity/cda:addr/cda:state').text
        assert_equal provider.addresses.first.zip, doc.at_xpath('cda:ClinicalDocument/cda:documentationOf/cda:serviceEvent/cda:performer/cda:assignedEntity/cda:addr/cda:postalCode').text
        assert_equal provider.addresses.first.country, doc.at_xpath('cda:ClinicalDocument/cda:documentationOf/cda:serviceEvent/cda:performer/cda:assignedEntity/cda:addr/cda:country').text
        assert_equal provider.npi, doc.at_xpath('cda:ClinicalDocument/cda:documentationOf/cda:serviceEvent/cda:performer/cda:assignedEntity/cda:id[@root="2.16.840.1.113883.4.6"]/@extension').value
        assert_equal provider.ccn, doc.at_xpath('cda:ClinicalDocument/cda:documentationOf/cda:serviceEvent/cda:performer/cda:assignedEntity/cda:id[@root="2.16.840.1.113883.4.336"]/@extension').value
        assert_equal provider.tin, doc.at_xpath('cda:ClinicalDocument/cda:documentationOf/cda:serviceEvent/cda:performer/cda:assignedEntity/cda:representedOrganization/cda:id[@root="2.16.840.1.113883.4.2"]/@extension').value
      end

      def test_no_provider_roundtrip
        cqm_patient = generate_shell_patient('provider')
        doc = generate_doc(cqm_patient, @options)
        assert_equal '282N00000X', doc.at_xpath('cda:ClinicalDocument/cda:documentationOf/cda:serviceEvent/cda:performer/cda:assignedEntity/cda:code/@code').value
        assert_equal 'Carroll', doc.at_xpath('cda:ClinicalDocument/cda:documentationOf/cda:serviceEvent/cda:performer/cda:assignedEntity/cda:assignedPerson/cda:name/cda:family').text
        assert_equal 'Daryl', doc.at_xpath('cda:ClinicalDocument/cda:documentationOf/cda:serviceEvent/cda:performer/cda:assignedEntity/cda:assignedPerson/cda:name/cda:given').text
        assert_equal '16432 Jayme Viaduct Manor', doc.at_xpath('cda:ClinicalDocument/cda:documentationOf/cda:serviceEvent/cda:performer/cda:assignedEntity/cda:addr/cda:streetAddressLine').text
        assert_equal 'Clairland', doc.at_xpath('cda:ClinicalDocument/cda:documentationOf/cda:serviceEvent/cda:performer/cda:assignedEntity/cda:addr/cda:city').text
        assert_equal 'MS', doc.at_xpath('cda:ClinicalDocument/cda:documentationOf/cda:serviceEvent/cda:performer/cda:assignedEntity/cda:addr/cda:state').text
        assert_equal '38796', doc.at_xpath('cda:ClinicalDocument/cda:documentationOf/cda:serviceEvent/cda:performer/cda:assignedEntity/cda:addr/cda:postalCode').text
        assert_equal 'US', doc.at_xpath('cda:ClinicalDocument/cda:documentationOf/cda:serviceEvent/cda:performer/cda:assignedEntity/cda:addr/cda:country').text
        assert_equal '1982671962', doc.at_xpath('cda:ClinicalDocument/cda:documentationOf/cda:serviceEvent/cda:performer/cda:assignedEntity/cda:id[@root="2.16.840.1.113883.4.6"]/@extension').value
        assert_equal '463132', doc.at_xpath('cda:ClinicalDocument/cda:documentationOf/cda:serviceEvent/cda:performer/cda:assignedEntity/cda:id[@root="2.16.840.1.113883.4.336"]/@extension').value
        assert_equal '695939209', doc.at_xpath('cda:ClinicalDocument/cda:documentationOf/cda:serviceEvent/cda:performer/cda:assignedEntity/cda:representedOrganization/cda:id[@root="2.16.840.1.113883.4.2"]/@extension').value
      end

      def test_exhaustive_patient_roundtrip
        puts "\n========================= QRDA ROUNDTRIP ========================="
        cqm_patients = QDM::PatientGeneration.generate_exhaustive_data_element_patients(true)
        add_different_frequency_codes_to_medication(cqm_patients.find { |patient| patient.familyName.include? 'MedicationDispensed' })
        successful_count = 0
        cqm_patients.each do |cqm_patient|
          datatype_name = cqm_patient.givenNames[0]
          cqm_patient.qdmPatient.dataElements.each do |data_element|
            if (!data_element['negationRationale'].nil? && !data_element['reason'].nil?)
              data_element.reason = nil
            end
          end
          # Initial QRDA export
          begin
            exported_qrda = generate_doc(cqm_patient)
          rescue StandardError => e
            puts "\e[31mError exporting QRDA for datatype #{datatype_name}: #{e.message}\e[0m"
          end
          # Import patient from QRDA
          begin
            imported_patient, _warnings = @importer.parse_cat1(exported_qrda)
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
              if ((!change_info.parent.to_s.include? "effectiveTime") && (!change_info.name.include? "type") && (!change_info.name.include? "unit") && ((change_info.to_html =~ /root=/) != 1) && ((change_info.to_html =~ /extension=/) != 1) &&
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
        assert_equal 0, cqm_patients.count - successful_count
      end

      def test_exhaustive_qrda_validation
        skip_types = %w[Entity PatientEntity CarePartner Practitioner Organization CareGoal DiagnosisComponent Location]
        puts "\n========================= QRDA VALIDATION ========================="
        cqm_patients = QDM::PatientGeneration.generate_exhaustive_data_element_patients(true)
        add_different_frequency_codes_to_medication(cqm_patients.find { |patient| patient.familyName.include? 'MedicationDispensed' })
        validator = CqmValidators::Cat1R53.instance
        cda_validator = CqmValidators::CDA.instance
        successful_count = 0
        cqm_patients.each do |cqm_patient|
          datatype_name = cqm_patient.givenNames[0]
          cqm_patient.qdmPatient.dataElements.each do |data_element|
            if (!data_element['negationRationale'].nil? && !data_element['reason'].nil?)
              data_element.reason = nil
            end
          end
          begin
            exported_qrda = generate_doc(cqm_patient)
            errors = validator.validate(exported_qrda)
            cda_errors = cda_validator.validate(exported_qrda)
            if (errors.count.zero? && cda_errors.count.zero?)
              successful_count += 1
            end
            if (skip_types.include? datatype_name)
              puts "Ignoring results for datatype #{datatype_name}"
              successful_count += 1
            end
            errors.each do |error|
              # Un-comment this line to print on files with errors. Easier to debug.
              # File.write("#{datatype_name}.xml", exported_qrda.to_xml)
              puts "\e[31mQRDA Schematron Error In #{datatype_name}: #{error.message}\e[0m"
            end
            cda_errors.each do |error|
              puts "\e[31mCDA Schema Error In #{datatype_name}: #{error.message}\e[0m"
            end
          rescue StandardError => e
            puts "\e[31mException validating #{datatype_name}: #{e.message}\e[0m"
          end
        end
        known_issues = 0
        assert_equal 0, cqm_patients.count - successful_count - known_issues
      end
    end
  end
end
