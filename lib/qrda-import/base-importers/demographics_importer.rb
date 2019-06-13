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
        pcbd.dataElementCodes = [{ code: '21112-8', codeSystemOid: '2.16.840.1.113883.6.1' }]
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
      end

      def code_if_present(code_element)
        return unless code_element && code_element['code'] && (code_element['codeSystem'] || code_element['codeSystemOid'])
        oid = code_element['codeSystem'] || code_element['codeSystemOid']
        QDM::Code.new(code_element['code'], oid)
      end
    end
  end
end
