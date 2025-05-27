module QRDA
  module Cat1
    module DemographicsImporter
      def get_demographics(patient, doc, codes)
        patient_role_element = doc.at_xpath('/cda:ClinicalDocument/cda:recordTarget/cda:patientRole')
        patient_element = patient_role_element.at_xpath('./cda:patient')
        patient.givenNames = [patient_element.at_xpath('cda:name/cda:given').text]
        patient.familyName = patient_element.at_xpath('cda:name/cda:family').text
        patient.qdmPatient.birthDatetime = DateTime.parse(patient_element.at_xpath('cda:birthTime')['value'])
        pcbd = QDM::PatientCharacteristicBirthdate.new
        pcbd.birthDatetime = patient.qdmPatient.birthDatetime
        pcbd.dataElementCodes = [QDM::Code.new('21112-8', '2.16.840.1.113883.6.1')]
        codes.add("21112-8:2.16.840.1.113883.6.1")
        patient.qdmPatient.dataElements << pcbd

        pcs = QDM::PatientCharacteristicSex.new
        code_element = patient_element.at_xpath('cda:administrativeGenderCode')
        pcs.dataElementCodes = [code_if_present(code_element, codes)]
        patient.qdmPatient.dataElements << pcs unless pcs.dataElementCodes.compact.blank?

        pcr = QDM::PatientCharacteristicRace.new
        code_element = patient_element.at_xpath('cda:raceCode')
        pcr.dataElementCodes = [code_if_present(code_element, codes)]
        patient.qdmPatient.dataElements << pcr unless pcr.dataElementCodes.compact.blank?

        pce = QDM::PatientCharacteristicEthnicity.new
        code_element = patient_element.at_xpath('cda:ethnicGroupCode')
        pce.dataElementCodes = [code_if_present(code_element, codes)]
        patient.qdmPatient.dataElements << pce unless pce.dataElementCodes.compact.blank?
      end

      def code_if_present(code_element, codes)
        other_code = other_code_if_present(code_element, codes)
        return other_code if other_code
        return unless code_element && code_element['code'] && code_element['codeSystem']
        codes.add("#{code_element['code']}:#{code_element['codeSystem']}")
        QDM::Code.new(code_element['code'], code_element['codeSystem'])
      end

      def other_code_if_present(code_element, codes)
        return unless code_element['nullFlavor']
        translations = code_element.xpath('cda:translation')
        return if translations.blank?

        translations.each do |translation|
          return code_if_present(translation, codes)
        end
      end
    end
  end
end
