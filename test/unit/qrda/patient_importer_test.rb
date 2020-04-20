require_relative '../../test_helper'
require 'cqm/models'

module QRDA
  module Cat1
    class PatientImporterTest < MiniTest::Test
      def setup
        @importer = Cat1::PatientImporter.instance
        @patient = CQM::Patient.new
        @map = {}
      end

      def test_import_with_single_encounter
        doc = Nokogiri::XML(File.read('test/fixtures/qrda/single_encounter.xml'))
        doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
        doc.root.add_namespace_definition('sdtc', 'urn:hl7-org:sdtc')
        @importer.import_data_elements(@patient, doc, @map)
        assert_equal 1, @patient.qdmPatient.dataElements.length
      end

      def test_import_with_two_encounters
        doc = Nokogiri::XML(File.read('test/fixtures/qrda/two_encounters.xml'))
        doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
        doc.root.add_namespace_definition('sdtc', 'urn:hl7-org:sdtc')
        @importer.import_data_elements(@patient, doc, @map)
        assert_equal 2, @patient.qdmPatient.dataElements.length
      end

      def test_import_with_two_encounters_same_id_different_codes_same_time
        doc = Nokogiri::XML(File.read('test/fixtures/qrda/two_encounters_same_id_different_codes_same_time.xml'))
        doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
        doc.root.add_namespace_definition('sdtc', 'urn:hl7-org:sdtc')
        @importer.import_data_elements(@patient, doc, @map)
        assert_equal 2, @patient.qdmPatient.dataElements.length
      end

      def test_import_with_two_encounters_same_id_same_codes_different_time
        doc = Nokogiri::XML(File.read('test/fixtures/qrda/two_encounters_same_id_same_codes_different_time.xml'))
        doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
        doc.root.add_namespace_definition('sdtc', 'urn:hl7-org:sdtc')
        @importer.import_data_elements(@patient, doc, @map)
        assert_equal 2, @patient.qdmPatient.dataElements.length
      end

      def test_import_with_two_encounters_same_id_same_codes_same_time
        doc = Nokogiri::XML(File.read('test/fixtures/qrda/two_encounters_same_id_same_codes_same_time.xml'))
        doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
        doc.root.add_namespace_definition('sdtc', 'urn:hl7-org:sdtc')
        @importer.import_data_elements(@patient, doc, @map)
        assert_equal 1, @patient.qdmPatient.dataElements.length
      end

      def test_import_with_two_encounters_same_id_same_two_codes_same_time
        doc = Nokogiri::XML(File.read('test/fixtures/qrda/two_encounters_same_id_same_two_codes_same_time.xml'))
        doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
        doc.root.add_namespace_definition('sdtc', 'urn:hl7-org:sdtc')
        @importer.import_data_elements(@patient, doc, @map)
        assert_equal 1, @patient.qdmPatient.dataElements.length
      end

      def test_import_with_two_interventions_with_same_id
        doc = Nokogiri::XML(File.read('test/fixtures/qrda/two_interventions_with_same_id.xml'))
        doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
        doc.root.add_namespace_definition('sdtc', 'urn:hl7-org:sdtc')
        @importer.import_data_elements(@patient, doc, @map)
        assert_equal 1, @patient.qdmPatient.dataElements.length
      end

      def test_import_with_two_interventions_with_different_id
        doc = Nokogiri::XML(File.read('test/fixtures/qrda/two_interventions_with_different_id.xml'))
        doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
        doc.root.add_namespace_definition('sdtc', 'urn:hl7-org:sdtc')
        @importer.import_data_elements(@patient, doc, @map)
        assert_equal 2, @patient.qdmPatient.dataElements.length
      end

      def test_import_with_two_data_types_with_same_id
        doc = Nokogiri::XML(File.read('test/fixtures/qrda/two_data_types_with_same_id.xml'))
        doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
        doc.root.add_namespace_definition('sdtc', 'urn:hl7-org:sdtc')
        @importer.import_data_elements(@patient, doc, @map)
        assert_equal 2, @patient.qdmPatient.dataElements.length
      end
    end
  end
end
