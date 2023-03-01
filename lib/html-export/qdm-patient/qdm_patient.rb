require 'mustache'
class QdmPatient < Mustache
  include Qrda::Export::Helper::PatientViewHelper
  include HQMF::Util::EntityHelper

  self.template_path = __dir__

  def initialize(patient, include_style)
    @include_style = include_style
    @patient = patient
    @qdmPatient = patient.qdmPatient
    @patient_addresses = patient['addresses']
    @patient_email = patient['email']
    @patient_telecoms = patient['telecoms']
  end

  def patient_addresses
    @patient_addresses ||= [CQM::Address.new(
      use: 'HP',
      street: ['202 Burlington Rd.'],
      city: 'Bedford',
      state: 'MA',
      zip: '01730',
      country: 'US'
    )]
    address_str = ""
    @patient_addresses.each do |address|
      # create formatted address
      address_str += "<address>"
      address['street'].each { |street| address_str += "#{street}<br>" }
      address_str += "#{address['city']}, #{address['state']} #{address['zip']}<br> #{address['country']} </address>"
    end
    address_str
  end

  def patient_telecoms
    @patient_telecoms ||= [CQM::Telecom.new(use: 'HP', value: '555-555-2003')]
    # create formatted telecoms
    @patient_telecoms << CQM::Telecom.new(use: 'HP', value: @patient_email) if @patient_email
    @patient_telecoms.map { |telecom| "(#{telecom['use']}) #{telecom['value']}" }.join("<br>")
  end

  def include_style?
    @include_style
  end

  def data_elements
    de_hash = {}
    @qdmPatient.dataElements.each do |data_element|
      data_element['methodCode'] = data_element['method'] if data_element['method']
      de_hash[data_element._type] ? de_hash[data_element._type][:element_list] << data_element : de_hash[data_element._type] = { title: data_element._type, element_list: [data_element] }
    end
    JSON.parse(de_hash.values.to_json)
  end

  def unit_string
    return "#{trimed_value(self['value'])}" if !self['unit'] || self['unit'] == '1'
    "#{trimed_value(self['value'])} #{self['unit']}"
  end

  def trimed_value(number)
    i, f = number.to_i, number.to_f
    i == f ? i : f
  end

  def entity_string
    if care_partner_entity?
      "</br>&nbsp; Care Partner: #{identifier_for_element(self['identifier'])}
      </br>&nbsp; Care Partner Relationship: #{code_for_element(self['relationship'])}"
    elsif organization_entity?
      "</br>&nbsp; Organization: #{identifier_for_element(self['identifier'])}
      </br>&nbsp; Organization Type: #{code_for_element(self['organizationType'])}"
    elsif location_entity?
      "</br>&nbsp; Location: #{identifier_for_element(self['identifier'])}
      </br>&nbsp; Location Type: #{code_for_element(self['locationType'])}"
    elsif patient_entity?
      "</br>&nbsp; Patient: #{identifier_for_element(self['identifier'])}"
    elsif practitioner_entity?
      "</br>&nbsp; Practitioner: #{identifier_for_element(self['identifier'])}
      </br>&nbsp; Practitioner Role: #{code_for_element(self['role'])},
      </br>&nbsp; Practitioner Specialty: #{code_for_element(self['specialty'])},
      </br>&nbsp; Practitioner Qualification: #{code_for_element(self['qualification'])}"
    else
      "</br>&nbsp; Entity: #{identifier_for_element(self['identifier'])}"
    end
  end

  def identifier_string
    identifier_for_element(self)
  end

  def identifier_for_element(identifier)
    identifier ? "#{identifier['value']} (#{identifier['namingSystem']})" : ''
  end

  def code_code_system_string
    code_for_element(self)
  end

  def code_for_element(element)
    element ? "#{element['code']} (#{HQMF::Util::CodeSystemHelper.code_system_for(element['system'])})#{code_description(element)}" : ''
  end

  def code_system_name
    HQMF::Util::CodeSystemHelper.code_system_for(self['system'])
  end

  def code_description(element = self)
    has_descriptions = @patient.respond_to?(:code_description_hash) && !@patient.code_description_hash.empty?
    # mongo keys cannot contain '.', so replace all '.', key example: '21112-8:2_16_840_1_113883_6_1'
    return " - #{@patient.code_description_hash["#{element['code']}:#{element['system']}".tr('.', '_')]}" if has_descriptions
    # no code description available
    ""
  end

  def demographic_code_description(code)
    # only have code, don't need code system
    has_descriptions = code && @patient.respond_to?(:code_description_hash) && !@patient.code_description_hash.empty?
    if has_descriptions
      key = @patient.code_description_hash.keys.detect { |k| k.starts_with?("#{send(code)}:") }
      return " - #{@patient.code_description_hash[key]}"
    end
    ""
  end

  def result_string
    return unit_string if self['value']
    return code_code_system_string if self['code']

    # Checks to see if the result is a DateTime value, String, or Numeric
    begin
      DateTime.parse(self['result'])
    rescue ArgumentError, TypeError
      # If the value is not numeric, just print out the result
      self['result'].is_a?(Numeric) ? trimed_value(self['result']) : self['result']
    end
  end

  def nested_code_string
    code_for_element(self['code'])
  end

  def diagnosis_string
    dx_string = ''
    dx_string += "</br>&nbsp; rank: #{self['rank']}" if self['rank']
    dx_string += "</br>&nbsp; presentOnAdmissionIndicator: #{self['presentOnAdmissionIndicator']['code']}" if self['presentOnAdmissionIndicator']
    dx_string
  end

  def end_time?
    self['high'] && DateTime.parse(self['high']).year < 3000
  end
end
