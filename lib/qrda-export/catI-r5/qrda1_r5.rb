require 'mustache'
class Qrda1R5 < Mustache
  include Qrda::Export::Helper::DateHelper
  include Qrda::Export::Helper::ViewHelper
  include Qrda::Export::Helper::Cat1ViewHelper
  include Qrda::Export::Helper::PatientViewHelper

  self.template_path = __dir__

  def initialize(patient, measures, options = {})
    @patient = patient
    @qdmPatient = patient.qdmPatient
    @measures = measures
    @provider = options[:provider]
    @performance_period_start = options[:start_time]
    @performance_period_end = options[:end_time]
    @submission_program = options[:submission_program]
    @insurance_provider = JSON.parse(@qdmPatient.extendedData.insurance_providers) if @qdmPatient.extendedData && @qdmPatient.extendedData['insurance_providers']
  end

  def adverse_event
    JSON.parse(@qdmPatient.dataElements.where(hqmfOid: { '$in' => HQMF::Util::HQMFTemplateHelper.get_all_hqmf_oids('adverse_event', '') }).to_json)
  end

  def allergy_intolerance
    JSON.parse(@qdmPatient.dataElements.where(hqmfOid: { '$in' => HQMF::Util::HQMFTemplateHelper.get_all_hqmf_oids('allergy_intolerance', '') }).to_json)
  end

  def assessment_order
    JSON.parse(@qdmPatient.dataElements.where(hqmfOid: { '$in' => HQMF::Util::HQMFTemplateHelper.get_all_hqmf_oids('assessment', 'ordered') }).to_json)
  end

  def assessment_performed
    JSON.parse(@qdmPatient.dataElements.where(hqmfOid: { '$in' => HQMF::Util::HQMFTemplateHelper.get_all_hqmf_oids('assessment', 'performed') }).to_json)
  end

  def communication_performed
    JSON.parse(@qdmPatient.dataElements.where(hqmfOid: { '$in' => HQMF::Util::HQMFTemplateHelper.get_all_hqmf_oids('communication', 'performed') }).to_json)
  end

  def diagnosis
    JSON.parse(@qdmPatient.dataElements.where(hqmfOid: { '$in' => HQMF::Util::HQMFTemplateHelper.get_all_hqmf_oids('diagnosis', '') }).to_json)
  end

  def device_ordered
    JSON.parse(@qdmPatient.dataElements.where(hqmfOid: { '$in' => HQMF::Util::HQMFTemplateHelper.get_all_hqmf_oids('device', 'ordered') }).to_json)
  end

  def device_applied
    JSON.parse(@qdmPatient.dataElements.where(hqmfOid: { '$in' => HQMF::Util::HQMFTemplateHelper.get_all_hqmf_oids('device', 'applied') }).to_json)
  end

  def diagnostic_study_ordered
    JSON.parse(@qdmPatient.dataElements.where(hqmfOid: { '$in' => HQMF::Util::HQMFTemplateHelper.get_all_hqmf_oids('diagnostic_study', 'ordered') }).to_json)
  end

  def diagnostic_study_performed
    JSON.parse(@qdmPatient.dataElements.where(hqmfOid: { '$in' => HQMF::Util::HQMFTemplateHelper.get_all_hqmf_oids('diagnostic_study', 'performed') }).to_json)
  end

  def encounter_ordered
    JSON.parse(@qdmPatient.dataElements.where(hqmfOid: { '$in' => HQMF::Util::HQMFTemplateHelper.get_all_hqmf_oids('encounter', 'ordered') }).to_json)
  end

  def encounter_performed
    JSON.parse(@qdmPatient.dataElements.where(hqmfOid: { '$in' => HQMF::Util::HQMFTemplateHelper.get_all_hqmf_oids('encounter', 'performed') }).to_json)
  end

  def immunization_administered
    JSON.parse(@qdmPatient.dataElements.where(hqmfOid: { '$in' => HQMF::Util::HQMFTemplateHelper.get_all_hqmf_oids('immunization', 'administered') }).to_json)
  end

  def intervention_order
    JSON.parse(@qdmPatient.dataElements.where(hqmfOid: { '$in' => HQMF::Util::HQMFTemplateHelper.get_all_hqmf_oids('intervention', 'ordered') }).to_json)
  end

  def intervention_performed
    JSON.parse(@qdmPatient.dataElements.where(hqmfOid: { '$in' => HQMF::Util::HQMFTemplateHelper.get_all_hqmf_oids('intervention', 'performed') }).to_json)
  end

  def intervention_recommended
    JSON.parse(@qdmPatient.dataElements.where(hqmfOid: { '$in' => HQMF::Util::HQMFTemplateHelper.get_all_hqmf_oids('intervention', 'recommended') }).to_json)
  end

  def lab_test_performed
    JSON.parse(@qdmPatient.dataElements.where(hqmfOid: { '$in' => HQMF::Util::HQMFTemplateHelper.get_all_hqmf_oids('laboratory_test', 'performed') }).to_json)
  end

  def lab_test_ordered
    JSON.parse(@qdmPatient.dataElements.where(hqmfOid: { '$in' => HQMF::Util::HQMFTemplateHelper.get_all_hqmf_oids('laboratory_test', 'ordered') }).to_json)
  end

  def laboratory_test_recommended
    JSON.parse(@qdmPatient.dataElements.where(hqmfOid: { '$in' => HQMF::Util::HQMFTemplateHelper.get_all_hqmf_oids('laboratory_test', 'recommended') }).to_json)
  end

  def medication_active
    JSON.parse(@qdmPatient.dataElements.where(hqmfOid: { '$in' => HQMF::Util::HQMFTemplateHelper.get_all_hqmf_oids('medication', 'active') }).to_json)
  end

  def medication_administered
    JSON.parse(@qdmPatient.dataElements.where(hqmfOid: { '$in' => HQMF::Util::HQMFTemplateHelper.get_all_hqmf_oids('medication', 'administered') + HQMF::Util::HQMFTemplateHelper.get_all_hqmf_oids('substance', 'administered') }).to_json)
  end

  def medication_discharge
    JSON.parse(@qdmPatient.dataElements.where(hqmfOid: { '$in' => HQMF::Util::HQMFTemplateHelper.get_all_hqmf_oids('medication', 'discharge') }).to_json)
  end

  def medication_dispensed
    JSON.parse(@qdmPatient.dataElements.where(hqmfOid: { '$in' => HQMF::Util::HQMFTemplateHelper.get_all_hqmf_oids('medication', 'dispensed') }).to_json)
  end

  def medication_ordered
    JSON.parse(@qdmPatient.dataElements.where(hqmfOid: { '$in' => HQMF::Util::HQMFTemplateHelper.get_all_hqmf_oids('medication', 'ordered') }).to_json)
  end

  def patient_care_experience
    JSON.parse(@qdmPatient.dataElements.where(hqmfOid: { '$in' => HQMF::Util::HQMFTemplateHelper.get_all_hqmf_oids('patient_care_experience', '') }).to_json)
  end

  def patient_characteristic_clinical_trial_participant
    JSON.parse(@qdmPatient.dataElements.where(hqmfOid: { '$in' => HQMF::Util::HQMFTemplateHelper.get_all_hqmf_oids('patient_characteristic', 'clinical_trial_participant') }).to_json)
  end

  def patient_characteristic_expired
    JSON.parse(@qdmPatient.dataElements.where(hqmfOid: { '$in' => HQMF::Util::HQMFTemplateHelper.get_all_hqmf_oids('patient_characteristic_expired', '') }).to_json)
  end

  def physical_exam_order
    JSON.parse(@qdmPatient.dataElements.where(hqmfOid: { '$in' => HQMF::Util::HQMFTemplateHelper.get_all_hqmf_oids('physical_exam', 'ordered') }).to_json)
  end
  
  def physical_exam_performed
    JSON.parse(@qdmPatient.dataElements.where(hqmfOid: { '$in' => HQMF::Util::HQMFTemplateHelper.get_all_hqmf_oids('physical_exam', 'performed') }).to_json)
  end

  def physical_exam_recommended
    JSON.parse(@qdmPatient.dataElements.where(hqmfOid: { '$in' => HQMF::Util::HQMFTemplateHelper.get_all_hqmf_oids('physical_exam', 'recommended') }).to_json)
  end

  def procedure_order
    JSON.parse(@qdmPatient.dataElements.where(hqmfOid: { '$in' => HQMF::Util::HQMFTemplateHelper.get_all_hqmf_oids('procedure', 'ordered') }).to_json)
  end

  def procedure_performed
    JSON.parse(@qdmPatient.dataElements.where(hqmfOid: { '$in' => HQMF::Util::HQMFTemplateHelper.get_all_hqmf_oids('procedure', 'performed') }).to_json)
  end

  def procedure_recommended
    JSON.parse(@qdmPatient.dataElements.where(hqmfOid: { '$in' => HQMF::Util::HQMFTemplateHelper.get_all_hqmf_oids('procedure', 'recommended') }).to_json)
  end

  def provider_care_experience
    JSON.parse(@qdmPatient.dataElements.where(hqmfOid: { '$in' => HQMF::Util::HQMFTemplateHelper.get_all_hqmf_oids('provider_care_experience', '') }).to_json)
  end

  def provider_characteristic
    JSON.parse(@qdmPatient.dataElements.where(hqmfOid: { '$in' => HQMF::Util::HQMFTemplateHelper.get_all_hqmf_oids('provider_characteristic', '') }).to_json)
  end

  def symptom
    JSON.parse(@qdmPatient.dataElements.where(hqmfOid: { '$in' => HQMF::Util::HQMFTemplateHelper.get_all_hqmf_oids('symptom', '') }).to_json)
  end
end
