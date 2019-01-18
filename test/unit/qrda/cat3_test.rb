require_relative '../../test_helper'
require 'cqm/models'
require 'cqm_validators'

module QRDA
  module Cat3
    class Cat3CVUTest < MiniTest::Test

      def test_cat3_good
        # Read in GOOD file in fixtures
        doc = File.open("test/fixtures/cat3/qrda_cat_3_no_errors.xml") { |f| Nokogiri::XML(f) }
        # Send file thru validator...
        good_errors = CqmValidators::Cat3R21.instance.validate(doc, file_name: 'test')
        # Shouldn't have any errors
        assert_equal [], good_errors, 'Should be empty set of errors for a good schema'
      end

      def test_cat3_bad
        # Read in BAD file in fixtures ("USA" is in there instead of "US")
        doc = File.open("test/fixtures/cat3/qrda_cat_3_with_errors.xml") { |f| Nokogiri::XML(f) }
        # Send file thru validator...
        bad_errors = CqmValidators::Cat3R21.instance.validate(doc, file_name: 'test')
        # Check if the error string below is in the array of errors (it should be)
        error_string = "@code=\"US\" (CONF:3338-17227)."
        bad_errors.any?{|err| err.message.include?(error_string)}
        # If bad_errors is true (we had the expected errors we were looking for), this test should pass
        assert bad_errors
      end

    end
  end
end
