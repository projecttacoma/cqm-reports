require_relative '../../test_helper'
require 'cqm/models'

module QRDA
  class DataElementTest < MiniTest::Test
    def setup
      @time = Time.now
      @example_elem = QDM::AdverseEvent.new(
        authorDatetime: @time,
        dataElementCodes: [
          QDM::Code.new('code_1', 'code_system_1')
        ]
      )
    end

    def test_merge_same_element_type
      severity_code = QDM::Code.new('severity_1', 'severity_system_1')
      test_elem = QDM::AdverseEvent.new(
        authorDatetime: @time + 1000,
        severity: severity_code,
        dataElementCodes: [
          QDM::Code.new('code_2', 'code_system_1')
        ]
      )
      
      @example_elem.merge!(test_elem)

      # Fields that are in the merged element but nil in the original should be set from merged
      assert_equal(@example_elem.severity, severity_code)

      # Fields that are not nil in the original shouldn't be overwritten
      assert_equal(@time, @example_elem.authorDatetime)

      # DataElementCodes should get merged
      assert_equal(2, @example_elem.dataElementCodes.count)
      assert_equal([QDM::Code.new('code_1', 'code_system_1'), QDM::Code.new('code_2', 'code_system_1')], @example_elem.codes)
    end

    def test_merge_codes
      test_elem = QDM::AdverseEvent.new(
        dataElementCodes: [
          QDM::Code.new('code_1', 'code_system_1')
        ]
      )
      
      @example_elem.merge!(test_elem)

      # DataElementCodes should get merged (same code should only be on a resultant DataElement once)
      assert_equal(1, @example_elem.dataElementCodes.count)
      assert_equal([QDM::Code.new('code_1', 'code_system_1')], @example_elem.codes)
    end

    def test_merge_different_element_types
      reason_code = QDM::Code.new('reason', 'reason_system_1')
      test_elem = QDM::DeviceOrder.new(
        authorDatetime: @time,
        reason: reason_code,
        dataElementCodes: [
          QDM::Code.new('code_2', 'code_system_1')
        ]
      )
      
      @example_elem.merge!(test_elem)

      # Merging two elements that aren't the same (e.g. AdverseEvent and DeviceOrder)
      # Should lead to no changes in the original element or the merged element
      assert_equal(@example_elem.severity, nil)
      assert_equal(1, @example_elem.dataElementCodes.count)
      assert_equal([QDM::Code.new('code_1', 'code_system_1')], @example_elem.codes)

      assert_equal(test_elem.reason, reason_code)
      assert_equal(1, test_elem.dataElementCodes.count)
      assert_equal([QDM::Code.new('code_2', 'code_system_1')], test_elem.codes)
    end
  end
end
