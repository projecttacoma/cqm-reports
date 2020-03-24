require 'mustache'
class QdmPatient < Mustache
  include Qrda::Export::Helper::PatientViewHelper
  include HQMF::Util::EntityHelper

  self.template_path = __dir__

  def initialize(patient, include_style)
    @include_style = include_style
    @patient = patient
    @qdmPatient = patient.qdmPatient
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
    return "#{self['value']} " unless self['unit']
    "#{self['value']} #{self['unit']}"
  end

  def entity_string
    if care_partner_entity?
      "Care partner #{identifier_for_element(self['identifier'])} with relationship #{code_for_element(self['relationship'])}"
    elsif organization_entity?
      "Organization #{identifier_for_element(self['identifier'])} with type #{code_for_element(self['type'])}"
    elsif patient_entity?
      "Patient #{identifier_for_element(self['identifier'])}"
    elsif practitioner_entity?
      "Practitioner #{identifier_for_element(self['identifier'])} with role #{code_for_element(self['role'])}, \\
      specialty #{code_for_element(self['specialty'])}, \\
      and qualification #{code_for_element(self['qualification'])}"
    else
      "Entity #{identifier_for_element(self['identifier'])}"
    end
  end

  def identifier_string
    identifier_for_element(self)
  end

  def identifier_for_element(identifier)
    "#{identifier['value']} (#{identifier['namingSystem']})"
  end

  def code_code_system_string
    code_for_element(self)
  end

  def code_for_element(element)
    "#{element['code']} (#{HQMF::Util::CodeSystemHelper.code_system_for(element['system'])})"
  end

  def code_system_name
    HQMF::Util::CodeSystemHelper.code_system_for(self['system'])
  end

  def result_string
    return unit_string if self['value']
    return code_code_system_string if self['code']

    ''
  end

  def facility_string
    "#{self['code']['code']} (#{self['code']['codeSystem']})"
  end

  def end_time?
    self['high'] && DateTime.parse(self['high']).year < 3000
  end
end
