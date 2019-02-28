require 'byebug'
module Qrda
  module Export
    module Helper
      module Cat1ViewHelper
        def insurance_provider_code_and_code_system
          "code=\"#{self['codes'].values.first[0]}\" codeSystem=\"#{code_system_oid(self['codes'].keys.first)}\" codeSystemName=\"#{self['codes'].keys.first}\""
        end

        def negation_ind
          self[:negationRationale].nil? ? "" : "negationInd=\"true\""
        end

        def negated
          self[:negationRationale].nil? ? false : true
        end

        def multiple_codes?
          self[:dataElementCodes].size > 1
        end

        def display_author_dispenser_id?
          self['qdmCategory'] == 'medication' && self['qdmStatus'] == 'dispensed'
        end

        def display_author_prescriber_id?
          self['qdmCategory'] == 'medication' && self['qdmStatus'] == 'order'
        end

        def code_system_oid(name)
          Qrda::Export::Helper::CodeSystemHelper.oid_for_code_system(name)
        end

        def code_and_codesystem
          "code=\"#{self['code']}\" codeSystem=\"#{code_system_oid(self['codeSystem'])}\" codeSystemName=\"#{self['codeSystem']}\""
        end

        def primary_code_and_codesystem
          "code=\"#{self[:dataElementCodes][0]['code']}\" codeSystem=\"#{code_system_oid(self[:dataElementCodes][0]['codeSystem'])}\" codeSystemName=\"#{self[:dataElementCodes][0]['codeSystem']}\""
        end

        def translation_codes_and_codesystem_list
          translation_list = ""
          self[:dataElementCodes].each_with_index do |_dec, index|
            next if index.zero?

            translation_list += "<translation code=\"#{self[:dataElementCodes][index]['code']}\" codeSystem=\"#{code_system_oid(self[:dataElementCodes][index]['codeSystem'])}\" codeSystemName=\"#{self[:dataElementCodes][index]['codeSystem']}\"/>"
          end
          translation_list
        end

        def result_value
          return "<value xsi:type=\"CD\" nullFlavor=\"UNK\"/>" unless self['result']

          result_string = if self['result'].is_a? Array
                            result_value_as_string(self['result'][0])
                          elsif self['result'].is_a? Hash
                            result_value_as_string(self['result'])
                          elsif !self['result'].nil?
                            "<value xsi:type=\"PQ\" value=\"#{self['result']}\" unit=\"1\"/>"
                          end
          result_string
        end

        def result_value_as_string(result)
          return "<value xsi:type=\"CD\" nullFlavor=\"UNK\"/>" unless result
          return "<value xsi:type=\"CD\" code=\"#{result['code']}\" codeSystem=\"#{code_system_oid(result['codeSystem'])}\" codeSystemName=\"#{result['codeSystem']}\"/>" if result['code']
          return "<value xsi:type=\"PQ\" value=\"#{result['value']}\" unit=\"#{result['unit']}\"/>" if result['unit']
        end

        def authorDateTimeOrDispenserId
          self['authorDatetime'] || self['dispenserId']
        end

      end
    end
  end
end
