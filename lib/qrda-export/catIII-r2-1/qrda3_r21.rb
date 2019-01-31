require 'mustache'
class Qrda3R21 < Mustache
  include Qrda::Export::Helper::DateHelper
  include Qrda::Export::Helper::ViewHelper

  self.template_path = __dir__

  def initialize(aggregate_results, measures, options = {})
    @aggregate_results = aggregate_results
    @measures = measures
    @measure_result_hash = {}
    @measures.each do |measure|
      @measure_result_hash[measure.hqmf_id] = { hqmf_id: measure.hqmf_id, hqmf_set_id: measure.hqmf_set_id, description: measure.description, measure_data: [], aggregate_count: [] }
    end
    @aggregate_results.each do |_key, aggregate_result|
      @measure_result_hash[aggregate_result.measure_id].measure_data << aggregate_result
    end
    @measure_result_hash.each do |key, hash|
      @measure_result_hash[key][:aggregate_count] = agg_results(key, hash.measure_data)
    end
    @provider = options[:provider]
    @performance_period_start = options[:start_time]
    @performance_period_end = options[:end_time]
    @submission_program = options[:submission_program]
  end

  def agg_results(measure_id, cache_entries)
    aggregate_count = Qrda::Export::Helper::AggregateCount.new(measure_id)
    cache_entries.each do |cache_entry|
      aggregate_count.add_entry(cache_entry)
    end
    aggregate_count
  end

  def measure_results
    @measure_result_hash.values.as_json
  end

  def population_type
    self['type'] == 'IPP' ? 'IPOP' : self['type']
  end

  def population_value
    self['value'].round
  end

  def msrpopl?
    self['type'] == 'MSRPOPL'
  end

  def not_observ?
    self['type'] != 'OBSERV'
  end

  def stratification_observation
    observation = @measure_result_hash[self['measure_id']].aggregate_count.populations.find {|p| p.type == "OBSERV"}
    stratification_observation = @measure_result_hash[self['measure_id']].aggregate_count.populations.find {|p| p.type == "OBSERV"}.stratifications.find {|s| s.id == self['id'] }
    stratification_observation.id = observation.id
    stratification_observation
  end

  def population_observation
    @measure_result_hash[self['measure_id']].aggregate_count.populations.find {|p| p.type == "OBSERV"}
  end

  def supplemental_template_ids
    case self['type']
    when 'RACE'
      [{ tid: '2.16.840.1.113883.10.20.27.3.8', extension: '2016-09-01' }]
    when 'ETHNICITY'
      [{ tid: '2.16.840.1.113883.10.20.27.3.7', extension: '2016-09-01' }]
    when 'SEX'
      [{ tid: '2.16.840.1.113883.10.20.27.3.6', extension: '2016-09-01' }]
    when 'PAYER'
      [{ tid: '2.16.840.1.113883.10.20.27.3.9', extension: '2016-02-01' }]
    end
  end

  def supplemental_data_code
    case self['type']
    when 'RACE'
      [{ supplemental_data_code: '72826-1', supplemental_data_code_system: '2.16.840.1.113883.6.1' }]
    when 'ETHNICITY'
      [{ supplemental_data_code: '69490-1', supplemental_data_code_system: '2.16.840.1.113883.6.1' }]
    when 'SEX'
      [{ supplemental_data_code: '76689-9', supplemental_data_code_system: '2.16.840.1.113883.6.1' }]
    when 'PAYER'
      [{ supplemental_data_code: '48768-6', supplemental_data_code_system: '2.16.840.1.113883.6.1' }]
    end
  end

  def supplemental_data_value_code_system
    case self['type']
    when 'RACE'
      '2.16.840.1.113883.6.238'
    when 'ETHNICITY'
      '2.16.840.1.113883.6.238'
    when 'SEX'
      '2.16.840.1.113883.5.1'
    when 'PAYER'
      '2.16.840.1.113883.3.221.5'
    end
  end

  def unknown_supplemental_value?
    self['code'] == "" || self['code'] == "UNK"
  end

  def population_supplemental_data
    reformat_supplemental_data(self['supplemental_data'])
  end

  def reformat_supplemental_data(supplemental_data)
    supplemental_data_array = []
    supplemental_data.each do |supplemental_data_key, counts|
      counts.each do |key, value|
        supplemental_data_count = { code: key, value: value, type: supplemental_data_key }
        supplemental_data_array << supplemental_data_count
      end
    end
    supplemental_data_array
  end

end