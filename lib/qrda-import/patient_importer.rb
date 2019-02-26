module QRDA
  module Cat1
    # This class is the central location for taking a QRDA Cat 1 XML document and converting it
    # into the processed form we store in MongoDB. The class does this by running each measure
    # independently on the XML document
    #
    # This class is a Singleton. It should be accessed by calling PatientImporter.instance
    class PatientImporter
      include Singleton
      include DemographicsImporter

      def initialize
        # This differs from other HDS patient importers in that sections can have multiple importers
        @data_element_importers = []

        @data_element_importers << generate_importer(EncounterPerformedImporter)
        @data_element_importers << generate_importer(LaboratoryTestPerformedImporter)
        @data_element_importers << generate_importer(DiagnosisImporter)
        @data_element_importers << generate_importer(InterventionOrderImporter)
        @data_element_importers << generate_importer(ProcedurePerformedImporter)
        @data_element_importers << generate_importer(MedicationActiveImporter)
        @data_element_importers << generate_importer(AllergyIntoleranceImporter)
        @data_element_importers << generate_importer(MedicationOrderImporter)
        @data_element_importers << generate_importer(DiagnosticStudyOrderImporter)

        @data_element_importers << generate_importer(AdverseEventImporter)
        @data_element_importers << generate_importer(AssessmentPerformedImporter)
        @data_element_importers << generate_importer(AssessmentOrderImporter)
        @data_element_importers << generate_importer(CommunicationPerformedImporter)
        @data_element_importers << generate_importer(DeviceAppliedImporter)
        @data_element_importers << generate_importer(DeviceOrderImporter)
        @data_element_importers << generate_importer(DiagnosticStudyPerformedImporter)
        @data_element_importers << generate_importer(EncounterOrderImporter)
        @data_element_importers << generate_importer(ImmunizationAdministeredImporter)
        @data_element_importers << generate_importer(InterventionPerformedImporter)
        @data_element_importers << generate_importer(InterventionRecommendedImporter)
        @data_element_importers << generate_importer(LaboratoryTestOrderImporter)
        @data_element_importers << generate_importer(MedicationAdministeredImporter)
        @data_element_importers << generate_importer(MedicationDischargeImporter)
        @data_element_importers << generate_importer(MedicationDispensedImporter)
        @data_element_importers << generate_importer(PatientCareExperienceImporter)
        @data_element_importers << generate_importer(PatientCharacteristicClinicalTrialParticipantImporter)
        @data_element_importers << generate_importer(PatientCharacteristicExpiredImporter)
        @data_element_importers << generate_importer(PhysicalExamOrderImporter)
        @data_element_importers << generate_importer(PhysicalExamPerformedImporter)
        @data_element_importers << generate_importer(PhysicalExamRecommendedImporter)
        @data_element_importers << generate_importer(ProcedureOrderImporter)
        @data_element_importers << generate_importer(ProcedureRecommendedImporter)
        @data_element_importers << generate_importer(ProviderCareExperienceImporter)
        @data_element_importers << generate_importer(ProviderCharacteristicImporter)
        @data_element_importers << generate_importer(SubstanceAdministeredImporter)
        @data_element_importers << generate_importer(SubstanceRecommendedImporter)
        @data_element_importers << generate_importer(SymptomImporter)

      end 

      def parse_cat1(doc)
        patient = CQM::Patient.new
        entry_id_map = {}
        import_data_elements(patient, doc, entry_id_map)
        normalize_references(patient, entry_id_map)
        get_demographics(patient, doc)
        patient
      end

      def import_data_elements(patient, doc, entry_id_map)
        context = doc.xpath("/cda:ClinicalDocument/cda:component/cda:structuredBody/cda:component/cda:section[cda:templateId/@root = '2.16.840.1.113883.10.20.24.2.1']")
        nrh = NarrativeReferenceHandler.new
        nrh.build_id_map(doc)
        @data_element_importers.each do |entry_package|
          data_elements, id_map = entry_package.package_entries(context, nrh)
          new_data_elements = []

          id_map.each_value do |elem_ids|
            
            elem_id = elem_ids.first
            data_element = data_elements.find { |de| de.id == elem_id }

            elem_ids[1,elem_ids.length].each do |merge_id|
              merge_element = data_elements.find { |de| de.id == merge_id }
              data_element.merge!(merge_element)
            end

            new_data_elements << data_element
          end

          patient.qdmPatient.dataElements << new_data_elements
          entry_id_map.merge!(id_map)
        end
      end

      def get_patient_expired(record, doc)
        entry_elements = doc.xpath("/cda:ClinicalDocument/cda:component/cda:structuredBody/cda:component/cda:section[cda:templateId/@root = '2.16.840.1.113883.10.20.24.2.1']/cda:entry/cda:observation[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.54']")
        return unless entry_elements.empty?

        record.expired = true
        record.deathdate = DateTime.parse(entry_elements.at_xpath("./cda:effectiveTime/cda:low")['value']).to_i
      end

      def normalize_references(patient, entry_id_map)
        patient.qdmPatient.dataElements.each do |data_element|
          next unless data_element.respond_to?(:relatedTo) && data_element.relatedTo

          relations_to_add = []
          data_element.relatedTo.each do |related_to|
            relations_to_add << entry_id_map[related_to.value]
          end
          data_element.relatedTo.destroy
          relations_to_add.each do |relation_to_add|
            data_element.relatedTo << relation_to_add
          end
        end
      end

      private

      def generate_importer(importer_class)
        EntryPackage.new(importer_class.new)
      end
    end
  end
end
