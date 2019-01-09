require 'simplecov'
require 'codecov'
SimpleCov.start do
  add_filter "test/"
  track_files 'lib/**/*.rb'
end

SimpleCov.formatter = SimpleCov::Formatter::Codecov
