module QRDA
  module Cat1
    class SectionImporter
      attr_accessor :check_for_usable, :status_xpath, :code_xpath

      def initialize(entry_finder)
        @entry_finder = entry_finder
        @code_xpath = "./cda:code"
        @entry_id_map = {}
        @check_for_usable = true
        @entry_class = QDM::DataElement
      end

      # Traverses an HL7 CDA document passed in and creates an Array of Entry
      # objects based on what it finds
      # @param [Nokogiri::XML::Document] doc It is expected that the root node of this document
      #        will have the "cda" namespace registered to "urn:hl7-org:v3"
      #        measure definition
      # @return [Array] will be a list of Entry objects
      def create_entries(doc, nrh = NarrativeReferenceHandler.new)
        entry_list = []
        @entry_id_map = {}
        entry_elements = @entry_finder.entries(doc)
        entry_elements.each do |entry_element|
          entry = create_entry(entry_element, nrh)
          if @check_for_usable
            entry_list << entry if usable_entry?(entry)
          else
            entry_list << entry
          end
        end
        [entry_list, @entry_id_map]
      end

      def usable_entry?(entry)
        entry.dataElementCodes.present?
      end

      def create_entry(entry_element, _nrh = NarrativeReferenceHandler.new)
        entry = @entry_class.new
        # This is the id found in the QRDA file
        entry_qrda_id = extract_id(entry_element, @id_xpath)
        # Create a hash to map all of entry.ids to the same QRDA ids. This will be used to merge QRDA entries
        # that represent the same event. 
        @entry_id_map["#{entry_qrda_id.value}_#{entry_qrda_id.namingSystem}"] ||= []
        @entry_id_map["#{entry_qrda_id.value}_#{entry_qrda_id.namingSystem}"] << entry.id
        entry.dataElementCodes = extract_codes(entry_element, @code_xpath)
        extract_dates(entry_element, entry)
        if @result_xpath
          entry.result = extract_result_values(entry_element)
        end
        extract_reason_or_negation(entry_element, entry)
        entry
      end

      private

      def extract_id(parent_element, id_xpath)
        id_element = parent_element.at_xpath(id_xpath)
        return unless id_element

        # If an extension is not included, use the root as the value.  Other wise use the extension
        value = id_element['extension'] || id_element['root']
        identifier = QDM::Id.new(value: value, namingSystem: id_element['root'])
        identifier
      end

      def extract_codes(coded_element, code_xpath)
        code_list = []
        code_elements = coded_element.xpath(code_xpath)
        code_elements.each do |code_element|
          code_list << code_if_present(code_element)
          translations = code_element.xpath('cda:translation')
          translations.each do |translation|
            code_list << code_if_present(translation)
          end
        end
        code_list.compact
      end

      def code_if_present(code_element)
        return unless code_element && code_element['code'] && code_element['codeSystem']
        QDM::Code.new(code_element['code'], code_element['codeSystem'])
      end

      def extract_dates(parent_element, entry)
        entry.authorDatetime = extract_time(parent_element, @author_datetime_xpath) if @author_datetime_xpath
        entry.relevantPeriod = extract_interval(parent_element, @relevant_period_xpath) if @relevant_period_xpath
        entry.prevalencePeriod = extract_interval(parent_element, @prevalence_period_xpath) if @prevalence_period_xpath
      end

      def extract_interval(parent_element, interval_xpath)
        if parent_element.at_xpath("#{interval_xpath}/@value")
          low_time = DateTime.parse(parent_element.at_xpath(interval_xpath)['value'])
          high_time = DateTime.parse(parent_element.at_xpath(interval_xpath)['value'])
        end
        if parent_element.at_xpath("#{interval_xpath}/cda:low")
          low_time = DateTime.parse(parent_element.at_xpath("#{interval_xpath}/cda:low")['value'])
        end
        if parent_element.at_xpath("#{interval_xpath}/cda:high")
          high_time = if parent_element.at_xpath("#{interval_xpath}/cda:high")['value']
                        DateTime.parse(parent_element.at_xpath("#{interval_xpath}/cda:high")['value'])
                      else
                        DateTime.new(9999,1,1)
                      end
        end
        if parent_element.at_xpath("#{interval_xpath}/cda:center")
          low_time = Time.parse(parent_element.at_xpath("#{interval_xpath}/cda:center")['value'])
          high_time = Time.parse(parent_element.at_xpath("#{interval_xpath}/cda:center")['value'])
        end
        QDM::Interval.new(low_time, high_time).shift_dates(0)
      end

      def extract_time(parent_element, datetime_xpath)
        DateTime.parse(parent_element.at_xpath(datetime_xpath)['value']) if parent_element.at_xpath("#{datetime_xpath}/@value")
      end

      def frequency_as_coded_value(parent_element, frequency_xpath)
        # Find the frequency interval in hours
        frequency = extract_frequency_in_hours(parent_element, frequency_xpath)
        # If a frequency interval is not found, return nil
        return nil unless frequency[:low]
        # If a frequency interval is found, search for a corresponding Direct Reference Code
        key, value = Qrda::Export::Helper::FrequencyHelper::FREQUENCY_CODE_MAP.select { |_k,v| v[:low] == frequency[:low] && v[:high] == frequency[:high] && v[:institution_specified] == frequency[:institution_specified] && v[:unit] == frequency[:unit] }.first
        # If a Direct Reference Code isn't found, return nil
        return nil unless key
        # If a Direct Reference Code is found, return that code
        oid = value[:codeSystem] || value[:codeSystemOid]
        QDM::Code.new(key, oid)
      end

      def extract_frequency_in_hours(parent_element, frequency_xpath)
        # Need to go get low, high and institutionspecified
        low = parent_element.at_xpath("#{frequency_xpath}/@value").value.to_i if parent_element.at_xpath("#{frequency_xpath}/@value")
        low = parent_element.at_xpath("#{frequency_xpath}/cda:period/cda:low/@value").value.to_i if parent_element.at_xpath("#{frequency_xpath}/cda:period/cda:low/@value")
        unit = parent_element.at_xpath("#{frequency_xpath}/@unit").value if parent_element.at_xpath("#{frequency_xpath}/@unit")
        unit = parent_element.at_xpath("#{frequency_xpath}/cda:period/cda:low/@unit").value if parent_element.at_xpath("#{frequency_xpath}/cda:period/cda:low/@unit")
        high = parent_element.at_xpath("#{frequency_xpath}/cda:period/cda:high/@value").value.to_i if parent_element.at_xpath("#{frequency_xpath}/cda:period/cda:high/@value")
        institution_specified = parent_element.at_xpath("#{frequency_xpath}/@institutionSpecified") || false
        # Expected units are H (hours) and D (days)
        if unit && unit.upcase == 'D'
          low = low * 24 if low
          high = high * 34 if high
        end
        { low: low, high: high, unit: unit, institution_specified: institution_specified }
      end

      def extract_result_values(parent_element)
        result = []
        parent_element.xpath(@result_xpath).each do |elem|
          result << extract_result_value(elem)
        end
        result.size > 1 ? result : result.first 
      end

      def extract_result_value(value_element)
        return unless value_element && !value_element['nullFlavor']

        value = value_element['value']
        if value.present?
          return value.strip.to_i if (value_element['unit'] == "1" || value_element['unit'].nil?)

          return QDM::Quantity.new(value.strip.to_i, value_element['unit'])
        elsif value_element['code'].present?
          return code_if_present(value_element)
        end
      end

      # extracts the reason or negation data. if an element is negated and the code has a null flavor, a random code is assigned for calculation
      # coded_parent_element is the 'parent' element when the coded is nested (e.g., medication order)
      def extract_reason_or_negation(parent_element, entry, coded_parent_element = nil)
        coded_parent_element ||= parent_element
        reason_element = parent_element.xpath(".//cda:entryRelationship[@typeCode='RSON']/cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.88']/cda:value | .//cda:entryRelationship[@typeCode='RSON']/cda:act[cda:templateId/@root='2.16.840.1.113883.10.20.1.27']/cda:code")
        negation_indicator = parent_element['negationInd']
        unless reason_element.blank?
          if negation_indicator.eql?('true')
            entry.negationRationale = code_if_present(reason_element.first)
          else
            entry.reason = code_if_present(reason_element.first) unless @entry_does_not_have_reason
          end
        end
        extract_negated_code(coded_parent_element, entry)
      end

      def extract_negated_code(coded_parent_element, entry)
        code_elements = coded_parent_element.xpath(@code_xpath)
        code_elements.each do |code_element|
          if code_element['nullFlavor'] == 'NA' && code_element['sdtc:valueSet']
            entry.dataElementCodes = [{ code: code_element['sdtc:valueSet'], codeSystemOid: '1.2.3.4.5.6.7.8.9.10' }]
          end
        end
      end

      def extract_scalar(parent_element, scalar_xpath)
        scalar_element = parent_element.at_xpath(scalar_xpath)
        return unless scalar_element

        QDM::Quantity.new(scalar_element['value'].to_i, scalar_element['unit'])
      end

      def extract_components(parent_element)
        component_elements = parent_element.xpath(@components_xpath)
        components = []
        component_elements&.each do |component_element|
          component = QDM::Component.new
          component.code = code_if_present(component_element.at_xpath('./cda:code'))
          component.result = extract_result_value(component_element.at_xpath('./cda:value'))
          components << component
        end
        components
      end

      def extract_facility_locations(parent_element)
        facility_location_elements = parent_element.xpath(@facility_locations_xpath)
        facility_locations = []
        facility_location_elements&.each do |facility_location_element|
          facility_location = QDM::FacilityLocation.new
          participant_element = facility_location_element.at_xpath("./cda:participantRole[@classCode='SDLOC']/cda:code")
          facility_location.code = code_if_present(participant_element)
          facility_location.locationPeriod = extract_interval(facility_location_element, './cda:time')
          facility_locations << facility_location
        end
        facility_locations
      end

      def extract_related_to(parent_element)
        related_to_elements = parent_element.xpath(@related_to_xpath)
        related_ids = []
        related_to_elements.each do |related_to_element|
          related_ids << extract_id(related_to_element, './sdtc:id')
        end
        related_ids
      end

    end
  end
end
