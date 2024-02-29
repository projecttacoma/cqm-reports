require_relative './simplecov_init'
require 'erubis'
require 'active_support'
require 'mongoid'
require 'mongoid/tree'
require 'uuid'
require 'builder'
require 'csv'
require 'nokogiri'
require 'ostruct'
require 'log4r'
require 'memoist'
require 'protected_attributes'

PROJECT_ROOT = File.expand_path("../../", __FILE__)
require_relative File.join(PROJECT_ROOT, 'lib', 'cqm-reports')

require 'minitest/autorun'
require "minitest/reporters"

require 'bundler/setup'

Mongoid.load!('config/mongoid.yml', :test)

class Minitest::Test
  extend Minitest::Spec::DSL
  Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new
end