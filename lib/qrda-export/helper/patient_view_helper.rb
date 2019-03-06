module Qrda
  module Export
    module Helper
      module PatientViewHelper
        def provider
          JSON.parse(@provider.to_json) if @provider
        end

        def provider_addresses
          @provider['addresses']
        end

        def provider_street
          self['street'].join('')
        end

        def provider_npi
          @provider.npi
        end

        def provider_tin
          @provider.tin
        end

        def provider_ccn
          @provider.ccn
        end

        def provider_type_code
          @provider['specialty']
        end

        def mrn
          @patient.id.to_s
        end

        def given_name
          @patient.givenNames.join(' ')
        end

        def family_name
          @patient.familyName
        end

        def insurance_provider
          @insurance_provider
        end
      end
    end
  end
end
