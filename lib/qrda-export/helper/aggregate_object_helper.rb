module Qrda
  module Export
    module Helper
      module PopulationSelectors
        def numerator
          populations.find {|pop| pop.type == 'NUMER'}
        end

        def denominator
          populations.find {|pop| pop.type == 'DENOM'}
        end

        def denominator_exceptions
          populations.find {|pop| pop.type == 'DENEXCEP'}
        end

        def denominator_exclusions
          populations.find {|pop| pop.type == 'DENEX'}
        end

        def population_count(population_type, population_id)
          population = populations.find {|pop| pop.type == population_type && pop.id == population_id}
          if population
            population.value
          else
            0
          end
        end

        def population_id(population_type)
          populations.find {|pop| pop.type == population_type}.id
        end

        def method_missing(method, *args, &block)
          match_data = method.to_s.match(/^(.+)_count$/)
          if match_data
            population = send(match_data[1])
            if population
              population.value
            else
              0
            end
          else
            super
          end
        end

        def respond_to_missing?(method, *args)
          match_data = method.to_s.match(/^(.+)_count$/)
          !match_data.nil? or super
        end

        # Returns true if there is more than one IPP or DENOM, etc.
        def multiple_population_types?
          population_groups = populations.group_by(&:type)
          population_groups.values.any? { |pops| pops.size > 1 }
        end
      end
      class Population
        attr_accessor :type, :value, :id, :stratifications, :supplemental_data

        def initialize
          @stratifications = []
        end

        def add_stratification(id,value)
          stratifications << Stratification.new(id,value) unless stratifications.find {|st| st.id == id}
        end

      end

      class Stratification
        attr_accessor :id, :value
        def initialize(id,value)
          @id = id
          @value = value
        end

      end

      class PopulationGroup
        include PopulationSelectors
        attr_accessor :populations
        def performance_rate
          numerator_count.to_f / (performance_rate_denominator)
        end

        def performance_rate_denominator
          denominator_count - denominator_exclusions_count - denominator_exceptions_count
        end

        def is_cv?
          populations.any? {|pop| pop.type == 'MSRPOPL'}
        end

      end

      class AggregateCount
        attr_accessor :measure_id,  :populations, :population_groups

        def initialize(measure_id)
          @populations = []
          @measure_id = measure_id
          @population_groups = []
        end

        def add_entry(cache_entry, population_sets)
          population_set = population_sets.where(population_set_id: cache_entry.population_set_hash[:population_set_id]).first
          entry_populations = []
          %w[IPP DENOM NUMER NUMEX DENEX DENEXCEP MSRPOPL MSRPOPLEX OBSERV].each do |pop_code|
            next unless population_set.populations[pop_code] || pop_code == 'OBSERV'

            population = create_population_from_population_set(pop_code, population_set, cache_entry)
            if cache_entry.population_set_hash[:stratification_id]
              strat_id = population_set.stratifications.where(stratification_id: cache_entry.population_set_hash[:stratification_id]).first&.hqmf_id
              population.add_stratification(strat_id,cache_entry[pop_code])
            else
              population.value = cache_entry[pop_code]
              population.supplemental_data = cache_entry.supplemental_information.select { |si| si[:population] == pop_code }
            end
            entry_populations << population if population
          end
          return if population_groups.find {|pg| pg.populations.collect(&:id).compact.sort == entry_populations.collect(&:id).compact.sort }

          pg = PopulationGroup.new
          pg.populations = entry_populations
          population_groups << pg
        end

        def create_population_from_population_set(pop_code, population_set, cache_entry)
          population = if pop_code == 'OBSERV'
                         populations.find { |pop| pop.id == population_set.observations&.first&.hqmf_id }
                       elsif pop_code != 'STRAT'
                         populations.find { |pop| pop.id == population_set.populations[pop_code]&.hqmf_id }
                       end
          return population unless population.nil? && !cache_entry[:stratification_id]
          population = Population.new
          population.type = pop_code
          population.id = if pop_code == 'OBSERV'
                            population_set.observations&.first&.hqmf_id
                          else
                            population_set.populations[pop_code]&.hqmf_id
                          end
          populations << population
          population
        end

        def is_cv?
          populations.any? {|pop| pop.type == 'MSRPOPL'}
        end
      end
    end
  end
end