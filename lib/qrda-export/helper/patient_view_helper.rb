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

        def gender
          gender_element = patient.qdmPatient.dataElements.find { |de| de._type == "QDM::PatientCharacteristicSex" }
          gender_element.dataElementCodes.first.code
        end

        def birthdate
          patient.qdmPatient.birthDatetime
        end

        def expiration
          expired = patient.qdmPatient.dataElements.find { |de| de._type == "QDM::PatientCharacteristicExpired" }
          expired['expiredDatetime'] if expired
          "None"
        end

        def race
          race_element = patient.qdmPatient.dataElements.find { |de| de._type == "QDM::PatientCharacteristicRace" }
          race_element.dataElementCodes.first.code
        end

        def ethnic_group
          ethnic_element = patient.qdmPatient.dataElements.find { |de| de._type == "QDM::PatientCharacteristicEthnicity" }
          ethnic_element.dataElementCodes.first.code
        end

        def payer
          payer_element = patient.qdmPatient.dataElements.find { |de| de._type == "QDM::PatientCharacteristicPayer" }
          payer_element.dataElementCodes.first.code
        end
      end
    end
  end
end
