require 'mustache'
class QdmPatient < Mustache
  include Qrda::Export::Helper::PatientViewHelper

  self.template_path = __dir__

  def initialize(patient, include_style)
    @include_style = include_style
    @patient = patient
    @insurance_provider = JSON.parse(@patient.extendedData.insurance_providers) if @patient.extendedData && @patient.extendedData['insurance_providers']
  end

  def include_style?
    @include_style
  end

  def data_elements
    de_hash = {}
    @patient.dataElements.each do |data_element|
      de_hash[data_element._type] ? de_hash[data_element._type].element_list << data_element : de_hash[data_element._type] = { title: data_element._type, element_list: [data_element] }
    end
    JSON.parse(de_hash.values.to_json)
  end

  def unit_string
    "#{self['value']} #{self['unit']}"
  end

  def code_code_system_string
    "#{self['code']} (#{self['codeSystem']})"
  end

  def result_string
    return unit_string if self['unit']
    return code_code_system_string if self['code']

    ''
  end

  def facility_string
    "#{self['code']['code']} (#{self['code']['codeSystem']})"
  end

  def end_time?
    self['high'] && DateTime.parse(self['high']).year < 3000
  end

  def insurance_provider_code
    self['codes'].values.first[0]
  end
end
