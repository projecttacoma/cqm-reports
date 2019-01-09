require_relative '../../test_helper'
require 'cqm/models'

module QRDA
  module Cat1
    class PatientImporterTest < MiniTest::Test
      def setup
        @importer = Cat1::PatientImporter.instance
        @patient = QDM::Patient.new
        @map = {}
      end

      def test_patient_dedup
        doc = Nokogiri::XML(File.read('test/fixtures/qrda/0_1 N_GP Adult 2.xml'))
        doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
        doc.root.add_namespace_definition('sdtc', 'urn:hl7-org:sdtc')
        @importer.import_data_elements(@patient, doc, @map)
        
        assert_equal 2, @patient.dataElements.length
        de = @patient.dataElements.first
        assert_equal 2, de.dataElementCodes.length
        assert_operator de.dataElementCodes[0], :!=, de.dataElementCodes[1]
      end
    end
  end
end
