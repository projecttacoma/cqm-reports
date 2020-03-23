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
      "Care partner #{self['id']} with relationship #{self['relationship'].code_code_system_string}"
    elsif organization_entity?
      "Organization #{self['id']} with type #{self['type'].code_code_system_string}"
    elsif patient_entity?
      "Patient #{self['id']}"
    elsif practitioner_entity?
      "Practitioner #{self['id']} with role #{self['role'].code_code_system_string}, \\
      specialty #{self['specialty'].code_code_system_string}, \\
      and qualification #{self['qualification'].code_code_system_string}"
    else
      "Entity #{self['id']}"
    end
  end

  def code_code_system_string
    "#{self['code']} (#{HQMF::Util::CodeSystemHelper.code_system_for(self['system'])})"
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
