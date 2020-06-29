module QRDA
  module Cat1
    class SectionImporter
      attr_accessor :check_for_usable, :status_xpath, :code_xpath, :warnings

      def initialize(entry_finder)
        @entry_finder = entry_finder
        @code_xpath = "./cda:code"
        @entry_id_map = {}
        @check_for_usable = true
        @entry_class = QDM::DataElement
        @warnings = []
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
        extract_negation(entry_element, entry)
        entry
      end

      private

      def extract_id(parent_element, id_xpath)
        id_element = parent_element.at_xpath(id_xpath)
        return unless id_element

        # If an extension is not included, use the root as the value.  Other wise use the extension
        value = id_element['extension'] || id_element['root']
        identifier = QDM::Identifier.new(value: value, namingSystem: id_element['root'])
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
        if code_element && code_element['code'].nil? && code_element['sdtc:valueSet'].nil?
          @warnings << "Code element contains nullFlavor code and no valueset"
        end
        return unless code_element && code_element['code'] && code_element['codeSystem']
        QDM::Code.new(code_element['code'], code_element['codeSystem'])
      end

      def extract_dates(parent_element, entry)
        entry.authorDatetime = extract_time(parent_element, @author_datetime_xpath) if @author_datetime_xpath
        entry.prevalencePeriod = extract_interval(parent_element, @prevalence_period_xpath) if @prevalence_period_xpath
        entry.relevantDatetime = extract_time(parent_element, @relevant_date_time_xpath) if @relevant_date_time_xpath
        # If there is a relevantDatetime, don't look for a relevantPeriod
        return if entry.respond_to?(:relevantDatetime) && entry.relevantDatetime
        entry.relevantPeriod = extract_interval(parent_element, @relevant_period_xpath) if @relevant_period_xpath
      end

      def extract_interval(parent_element, interval_xpath)
        return nil unless parent_element.at_xpath(interval_xpath)
        if parent_element.at_xpath("#{interval_xpath}/@value")
          low_time = DateTime.parse(parent_element.at_xpath(interval_xpath)['value'])
          high_time = DateTime.parse(parent_element.at_xpath(interval_xpath)['value'])
        end
        if parent_element.at_xpath("#{interval_xpath}/cda:low")
          low_time = if parent_element.at_xpath("#{interval_xpath}/cda:low")['value']
                       DateTime.parse(parent_element.at_xpath("#{interval_xpath}/cda:low")['value'])
                     end
        end
        if parent_element.at_xpath("#{interval_xpath}/cda:high")
          high_time = if parent_element.at_xpath("#{interval_xpath}/cda:high")['value']
                        DateTime.parse(parent_element.at_xpath("#{interval_xpath}/cda:high")['value'])
                      end
        end
        if parent_element.at_xpath("#{interval_xpath}/cda:center")
          low_time = Time.parse(parent_element.at_xpath("#{interval_xpath}/cda:center")['value'])
          high_time = Time.parse(parent_element.at_xpath("#{interval_xpath}/cda:center")['value'])
        end
        if low_time && high_time && low_time > high_time
          # pass warning: current code continues as expected, but adds warning
          # TODO: add more information as needed
          @warnings << "Interval with low time after high time"
        end
        if low_time.nil? && high_time.nil?
          @warnings << "Interval with nullFlavor low time and nullFlavor high time"
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
        QDM::Code.new(key, value[:code_system])
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
          high = high * 24 if high
          unit = 'h'
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
          return value.strip.to_f if (value_element['unit'] == "1" || value_element['unit'].nil?)

          return QDM::Quantity.new(value.strip.to_f, value_element['unit'])
        elsif value_element['code'].present?
          return code_if_present(value_element)
        elsif value_element.text.present?
          @warnings << "Value with string type found. When possible, it's best practice to use a coded value or scalar."
          return value_element.text
        end
      end

      def extract_reason(parent_element)
        return unless @reason_xpath
        reason_element = parent_element.xpath(@reason_xpath)
        negation_indicator = parent_element['negationInd']
        # Return and do not set reason attribute if the entry is negated
        return nil if negation_indicator.eql?('true')
        
        reason_element.blank? ? nil : code_if_present(reason_element.first) 
      end

      def extract_negation(parent_element, entry)
        negation_element = parent_element.xpath("./cda:entryRelationship[@typeCode='RSON']/cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.88']/cda:value")
        negation_indicator = parent_element['negationInd']
        # Return and do not set negationRationale attribute if the entry is not negated
        return unless negation_indicator.eql?('true') 
        
        entry.negationRationale = code_if_present(negation_element.first) unless negation_element.blank?
        extract_negated_code(parent_element, entry)
      end

      def extract_negated_code(parent_element, entry)
        code_elements = parent_element.xpath(@code_xpath)
        code_elements.each do |code_element|
          if code_element['nullFlavor'] == 'NA' && code_element['sdtc:valueSet']
            entry.dataElementCodes = [{ code: code_element['sdtc:valueSet'], system: '1.2.3.4.5.6.7.8.9.10' }]
          end
        end
      end

      def extract_scalar(parent_element, scalar_xpath)
        scalar_element = parent_element.at_xpath(scalar_xpath)
        return unless scalar_element && scalar_element['value'].present?

        QDM::Quantity.new(scalar_element['value'].to_f, scalar_element['unit'])
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

      def extract_entity(parent_element, entity_xpath)
        care_partner_entity_element = parent_element.at_xpath(entity_xpath + "/cda:participantRole[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.160']")
        patient_entity_element = parent_element.at_xpath(entity_xpath + "/cda:participantRole[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.161']")
        practitioner_entity_element = parent_element.at_xpath(entity_xpath + "/cda:participantRole[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.162']")
        organization_entity_element = parent_element.at_xpath(entity_xpath + "/cda:participantRole[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.163']")
        return extract_care_partner_entity(care_partner_entity_element) if care_partner_entity_element
        return extract_patient_entity(patient_entity_element) if patient_entity_element
        return extract_practitioner_entity(practitioner_entity_element) if practitioner_entity_element
        return extract_organization_entity(organization_entity_element) if organization_entity_element
      end

      def extract_care_partner_entity(care_partner_entity_element)
        care_partner_entity = QDM::CarePartner.new
        care_partner_entity.identifier = extract_id(care_partner_entity_element, './cda:id')
        care_partner_entity.relationship = code_if_present(care_partner_entity_element.at_xpath('./cda:playingEntity/cda:code'))
        care_partner_entity
      end

      def extract_patient_entity(patient_entity_element)
        patient_entity = QDM::PatientEntity.new
        patient_entity.identifier = extract_id(patient_entity_element, './cda:id')
        patient_entity
      end

      def extract_practitioner_entity(practitioner_entity_element)
        practitioner_entity = QDM::Practitioner.new
        practitioner_entity.identifier = extract_id(practitioner_entity_element, './cda:id')
        practitioner_entity.role = code_if_present(practitioner_entity_element.at_xpath('./cda:code'))
        practitioner_entity.specialty = code_if_present(practitioner_entity_element.at_xpath('./cda:playingEntity/cda:code'))
        practitioner_entity.qualification = code_if_present(practitioner_entity_element.at_xpath('./cda:scopingEntity/cda:code'))
        practitioner_entity
      end

      def extract_organization_entity(organization_entity_element)
        organization_entity = QDM::Organization.new
        organization_entity.identifier = extract_id(organization_entity_element, './cda:id')
        organization_entity.type = code_if_present(organization_entity_element.at_xpath('./cda:playingEntity/cda:code'))
        organization_entity
      end
    end
  end
end
