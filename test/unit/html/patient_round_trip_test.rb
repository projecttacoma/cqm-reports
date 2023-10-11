require_relative '../../test_helper'
require 'cqm/models'
require 'byebug'

module HTML
  class PatientRoundTripTest < Minitest::Test
    # include QRDA::Cat1

    def setup
      create_test_measures_collection
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
      # TODO: use address etc??

      generate_shell_patient('html') # builds @cqm_patient and @qdm_patient
    end

    def test_demographics
      @cqm_patient.qdmPatient = @qdm_patient
      html = QdmPatient.new(@cqm_patient, true).render
      %w[gender race ethnicity birthdate payer].each do |cat|
        assert html.include?(@qdm_patient.get_data_elements('patient_characteristic', cat).first.dataElementCodes.first[:code])
      end
    end

    def test_all_html_attributes
      qdm_types = YAML.safe_load(File.read(File.expand_path('../../../config/qdm_types.yml', __dir__)), [], [], true)
      qdm_types.each do |qt|
        dt = QDM::PatientGeneration.generate_loaded_datatype("QDM::#{qt}")
        # check custom generated datatype for negationRationale field
        check_loaded_patient(QDM::PatientGeneration.generate_loaded_datatype("QDM::#{qt}", true), "negationRationale", qt) if dt.typed_attributes.keys.include?("negationRationale")
        # iterate through all relevant attributes for each data type, except negationRationale (checked above)
        dt.typed_attributes.keys.each do |field|
          next if %w[_id dataElementCodes description codeListId id _type type qdmTitle hqmfOid qrdaOid qdmCategory qdmVersion qdmStatus negationRationale targetOutcome statusDate linkedPatientId relatedTo].include? field
          # TODO: test targetOutcome (in Care Goal, not currently exported); relatedTo not generated
          # Other untested fields: statusDate linkedPatientId

          check_loaded_patient(dt, field, qt)
        end
      end
    end

    def check_loaded_patient(dt, field, qt)
      # create new qdm patient clone for dt/attribute combo
      qdm_patient = qdm_patient_for_attribute(dt, @qdm_patient)
      @cqm_patient.qdmPatient = qdm_patient

      html = QdmPatient.new(@cqm_patient, true).render
      assert html.include?(qt), "html should include QDM type #{qt}"
      assert dt.respond_to?(field), "datatype generation discrepancy, should contain field #{field}"
      check_for_type(html, dt, field)
    end

    def check_for_type(html, dt, field)
      attr = dt.send(field)
      if attr.respond_to?(:strftime)
        # timey object
        formatted_date = attr.localtime.strftime('%FT%T')
        assert html.include?(formatted_date), html_assertion_msg("date/time", formatted_date, field, dt)
      elsif attr.is_a?(Array)
        # components, relatedTo (irrelevant), facilityLocations, diagnoses (all code or nested code)
        attr.each do |attr_elem|
          top_code = get_key_or_field(attr_elem, 'code')
          if top_code.is_a?(Hash)
            # nested code
            assert html.include?(top_code[:code]), html_assertion_msg("nested code", top_code[:code], field, dt)
          else
            # code
            assert html.include?(top_code), html_assertion_msg("code", top_code, field, dt)
          end
        end
      elsif attr.is_a?(Integer) || attr.is_a?(String) || attr.is_a?(Float)
        assert html.include?(attr.to_s), html_assertion_msg("text", attr, field, dt)
        # qrdaOid
      elsif key_or_field?(attr, :low)
        # interval (may or may not include high)
        formatted_date = attr.low.strftime('%FT%T')
        assert html.include?(formatted_date), html_assertion_msg("low", formatted_date, field, dt)

      elsif key_or_field?(attr, :code)
        # must come after value to match result logic
        top_code = get_key_or_field(attr, :code)
        if top_code.is_a?(QDM::Code)
          # nested code
          assert html.include?(top_code.code), html_assertion_msg("nested code", top_code.code, field, dt)
        else
          # code
          assert html.include?(top_code), html_assertion_msg("code", top_code, field, dt)
        end
      elsif key_or_field?(attr, 'identifier')
        # entity
        assert html.include?(attr.identifier.value), html_assertion_msg("identifier", attr.identifier.value, field, dt)
      elsif key_or_field?(attr, :value)
        value = get_key_or_field(attr, :value)
        # value for basic identifier, result, or quantity (may or may not include unit)
        # must come before code to match result logic
        assert html.include?(value.to_s), html_assertion_msg("", value, field, dt)
      else
        # unlikely to get here
        assert false, "No known match for #{field} in #{dt._type}"
      end
    end

    def html_assertion_msg(type, value, field, dt)
      "html should include #{type} value #{value} for #{field} in #{dt._type}"
    end

    def key_or_field?(object, keyfield)
      return true if object.is_a?(Hash) && object.key?(keyfield)
      object.respond_to?(keyfield)
    end

    def get_key_or_field(object, keyfield)
      object.is_a?(Hash) ? object[keyfield] : object.send(keyfield)
    end

    def qdm_patient_for_attribute(dt, src_qdm_patient)
      # dt.reason = nil if ta[7] && dt.respond_to?(:reason)
      reset_datatype_fields(dt)

      single_dt_qdm_patient = src_qdm_patient.clone
      single_dt_qdm_patient.dataElements << dt
      single_dt_qdm_patient
    end

    def reset_datatype_fields(dt)
      dt.prescriberId = QDM::Identifier.new(namingSystem: '1.2.3.4', value: '1234') if dt.respond_to?(:prescriberId)
      dt.dispenserId = QDM::Identifier.new(namingSystem: '1.2.3.4', value: '1234') if dt.respond_to?(:dispenserId)
    end

    def generate_shell_patient(type)
      @cqm_patient = QDM::BaseTypeGeneration.generate_cqm_patient(type)
      @qdm_patient = QDM::BaseTypeGeneration.generate_qdm_patient
      # Add patient characteristics
      sex = QDM::PatientGeneration.generate_loaded_datatype('QDM::PatientCharacteristicSex')
      race = QDM::PatientGeneration.generate_loaded_datatype('QDM::PatientCharacteristicRace')
      ethnicity = QDM::PatientGeneration.generate_loaded_datatype('QDM::PatientCharacteristicEthnicity')
      birthdate = QDM::PatientGeneration.generate_loaded_datatype('QDM::PatientCharacteristicBirthdate')
      payer = QDM::PatientGeneration.generate_loaded_datatype('QDM::PatientCharacteristicPayer')
      @qdm_patient.dataElements.push(sex)
      @qdm_patient.dataElements.push(race)
      @qdm_patient.dataElements.push(ethnicity)
      @qdm_patient.dataElements.push(birthdate)
      @qdm_patient.dataElements.push(payer)
    end

    def create_test_measures_collection
      # Delete all existing for atomicity
      CQM::Measure.delete_all
      @measure = CQM::Measure.new
      @measure.hqmf_id = 'b794a9c2-8e83-11e8-9eb6-529269fb1459'
      @measure.hqmf_set_id = 'bdfa0e38-8e83-11e8-9eb6-529269fb1459'
      @measure.description = 'Test Measure'
      @measure.cql_libraries = []
      @measure.save
    end

  end
end
