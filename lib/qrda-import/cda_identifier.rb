require 'mongoid'

class CDAIdentifier
  include Mongoid::Document
  include Mongoid::Attributes::Dynamic

  field :root, type: String
  field :extension, type: String
  embedded_in :cda_identifiable, polymorphic: true

  def ==(other)
    return unless other.respond_to?(:root) && other.respond_to?(:extension)
    root == other.root && extension == other.extension
  end

  def hash
    "#{root}#{extension}".hash
  end
end
