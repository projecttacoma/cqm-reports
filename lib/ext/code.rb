module QDM
  class Code    
    def ==(other)
      return false unless other.is_a? QDM::Code

      (code == other.code) && (system == other.system) && (version == other.version)
    end

    alias eql? ==
  end
end
