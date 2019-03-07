module QRDA
  module Cat1
    module DemographicsImporter
      def get_demographics(patient, doc)
        patient_role_element = doc.at_xpath('/cda:ClinicalDocument/cda:recordTarget/cda:patientRole')
        patient_element = patient_role_element.at_xpath('./cda:patient')
        patient.givenNames = [patient_element.at_xpath('cda:name/cda:given').text]
        patient.familyName = patient_element.at_xpath('cda:name/cda:family').text
        patient.qdmPatient.birthDatetime = DateTime.parse(patient_element.at_xpath('cda:birthTime')['value'])
        pcbd = QDM::PatientCharacteristicBirthdate.new
        pcbd.birthDatetime = patient.qdmPatient.birthDatetime
        pcbd.dataElementCodes = [{ code: '21112-8', codeSystem: 'LOINC' }]
        patient.qdmPatient.dataElements << pcbd

        pcs = QDM::PatientCharacteristicSex.new
        code_element = patient_element.at_xpath('cda:administrativeGenderCode')
        pcs.dataElementCodes = [code_if_present(code_element)]
        patient.qdmPatient.dataElements << pcs

        pcr = QDM::PatientCharacteristicRace.new
        code_element = patient_element.at_xpath('cda:raceCode')
        pcr.dataElementCodes = [code_if_present(code_element)]
        patient.qdmPatient.dataElements << pcr

        pce = QDM::PatientCharacteristicEthnicity.new
        code_element = patient_element.at_xpath('cda:ethnicGroupCode')
        pce.dataElementCodes = [code_if_present(code_element)]
        patient.qdmPatient.dataElements << pce

        provider_element = doc.xpath("//cda:entry/cda:observation[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.55']")
        return if provider_element.blank?

        return if provider_element.blank?
        provider_code = provider_element.first.at_xpath('cda:value')['code']
        ip = {}
        ip['financial_responsibility_type'] = { 'code' => 'SELF', 'codeSystem' => 'HL7 Relationship Code' }
        ip['codes'] = { 'SOP' => [provider_code] }
        patient['insurance_providers'] = [ip]
      end

      def code_if_present(code_element)
        return unless code_element && code_element['codeSystem'] && code_element['code']

        QDM::Code.new(code_element['code'], HQMF::Util::CodeSystemHelper.code_system_for(code_element['codeSystem']))
      end
    end
  end
end
