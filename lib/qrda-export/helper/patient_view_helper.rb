module Qrda
  module Export
    module Helper
      module PatientViewHelper
        def provider
          JSON.parse(@provider.to_json) if @provider
        end

        def patient
          JSON.parse(@patient.to_json)
        end

        def provider_street
          self['street'].join('')
        end

        def provider_npi
          return nil unless self['ids']
          self['ids'].map { |id| id if id['namingSystem'] == '2.16.840.1.113883.4.6' }.compact
        end

        def provider_tin
          return nil unless self['ids']
          self['ids'].map { |id| id if id['namingSystem'] == '2.16.840.1.113883.4.2' }.compact
        end

        def provider_ccn
          return nil unless self['ids']
          self['ids'].map { |id| id if id['namingSystem'] == '2.16.840.1.113883.4.336' }.compact
        end

        def provider_type_code
          self['specialty']
        end

        def mrn
          @patient.id.to_s
        end

        def given_name
          self['givenNames'].join(' ')
        end

        def insurance_provider
          @insurance_provider
        end
      end
    end
  end
end
