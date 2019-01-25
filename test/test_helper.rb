require_relative './simplecov_init'
require 'factory_girl'
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
require_relative File.join(PROJECT_ROOT, 'lib', 'cqm_report')

require 'minitest/autorun'
require "minitest/reporters"

require 'bundler/setup'

Mongoid.load!('config/mongoid.yml', :test)
FactoryGirl.find_definitions

class Minitest::Test
  extend Minitest::Spec::DSL
  Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new
end