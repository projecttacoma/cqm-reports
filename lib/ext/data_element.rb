module QDM
  class DataElement
    def merge!(other)
      # ensure they're the same category (e.g. 'encounter')
      return unless qdmCategory == other.qdmCategory

      # ensure they're the same status (e.g. 'performed'), and that they both have a status set (or that they both don't)
      return if respond_to?(:qdmStatus) && !other.respond_to?(:qdmStatus)
      return if !respond_to?(:qdmStatus) && other.respond_to?(:qdmStatus)
      return if respond_to?(:qdmStatus) && other.respond_to?(:qdmStatus) && qdmStatus != other.qdmStatus
      
      # iterate over non-code fields
      fields.each_key do |field|
        next if field[0] == '_' || %w[dataElementCodes qdmCategory qdmVersion qdmStatus].include?(field)
        
        if send(field).nil?
          send(field + '=', other.send(field))
        end
      end

      self.dataElementCodes = dataElementCodes.concat(other.dataElementCodes).uniq
    end
  end
end
