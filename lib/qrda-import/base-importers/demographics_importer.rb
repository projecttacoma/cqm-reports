module QRDA
  module Cat1
    module DemographicsImporter
      def get_demographics(patient, doc)
        patient_role_element = doc.at_xpath('/cda:ClinicalDocument/cda:recordTarget/cda:patientRole')
        patient_element = patient_role_element.at_xpath('./cda:patient')
        patient.givenNames = [patient_element.at_xpath('cda:name/cda:given').text]
        patient.familyName = patient_element.at_xpath('cda:name/cda:family').text
        patient.birthDatetime = Time.parse(patient_element.at_xpath('cda:birthTime')['value']).utc
        pcbd = QDM::PatientCharacteristicBirthdate.new
        pcbd.birthDatetime = patient.birthDatetime
        pcbd.dataElementCodes = [{ code: '21112-8', codeSystem: 'LOINC' }]
        patient.dataElements << pcbd

        pcs = QDM::PatientCharacteristicSex.new
        gender_code = patient_element.at_xpath('cda:administrativeGenderCode')['code']
        pcs.dataElementCodes = [{ code: gender_code, codeSystem: 'AdministrativeGender' }]
        patient.dataElements << pcs

        pcr = QDM::PatientCharacteristicRace.new
        race_code = patient_element.at_xpath('cda:raceCode')['code']
        pcr.dataElementCodes = [{ code: race_code, codeSystem: 'cdcrec' }]
        patient.dataElements << pcr

        pce = QDM::PatientCharacteristicEthnicity.new
        ethnicity_code = patient_element.at_xpath('cda:ethnicGroupCode')['code']
        pce.dataElementCodes = [{ code: ethnicity_code, codeSystem: 'cdcrec' }]
        patient.dataElements << pce

        provider_element = doc.xpath("//cda:entry/cda:observation[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.55']")
        return if provider_element.blank?

        provider_code = provider_element.first.at_xpath('cda:value')['code']
        ip = {}
        ip['financial_responsibility_type'] = { 'code' => 'SELF', 'codeSystem' => 'HL7 Relationship Code' }
        ip['codes'] = { 'SOP' => [provider_code] }
        patient.extendedData = {}
        patient.extendedData['insurance_providers'] = JSON.generate([ip])
      end
    end
  end
end
