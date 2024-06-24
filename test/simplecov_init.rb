require 'simplecov'
require 'codecov'
SimpleCov.start do
  add_filter "test/"
  track_files 'lib/**/*.rb'
end

if ENV['CI'] == 'true'
  require 'simplecov-cobertura'
  SimpleCov.formatter = SimpleCov::Formatter::CoberturaFormatter
else
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
end
