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
          @patient.medical_record_number
        end

        def given_name
          @patient.givenNames.join(' ')
        end

        def family_name
          @patient.familyName
        end

        def birthdate
          @qdmPatient.birthDatetime.to_formatted_s(:number)
        end

        def gender
          @qdmPatient.dataElements.where(hqmfOid: '2.16.840.1.113883.10.20.28.3.55').first.dataElementCodes.first['code']
        end

        def race
          @qdmPatient.dataElements.where(hqmfOid: '2.16.840.1.113883.10.20.28.3.59').first.dataElementCodes.first['code']
        end

        def ethnic_group
          @qdmPatient.dataElements.where(hqmfOid: '2.16.840.1.113883.10.20.28.3.56').first.dataElementCodes.first['code']
        end

        def insurance_provider
          @insurance_provider
        end
      end
    end
  end
end
