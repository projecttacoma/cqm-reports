require 'uuid'
module Qrda
  module Export
    module Helper
      module ViewHelper
        def measures
          @measures.as_json
        end

        def random_id
          UUID.generate
        end

        def as_id
          self['value']
        end

        def object_id
          self[:_id]
        end

        def submission_program
          @submission_program
        end

        def medicare_beneficiary_identifier
          @medicare_beneficiary_identifier
        end

        def hicn
          @hicn
        end
      end
    end
  end
end