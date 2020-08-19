source 'https://rubygems.org'

gemspec :development_group => :test

gem 'mongoid', '~> 6.4.2'

gem 'protected_attributes_continued'

gem 'cqm-validators', git: 'https://github.com/projecttacoma/cqm-validators', branch: 'aggregate_result_model'

group :development, :test do
  gem 'bundler-audit'
  gem 'rubocop', '~> 0.52.1', require: false
end

group :development do
  gem 'rake'
  gem 'byebug'
end

group :test do
  gem 'cqm-models', '~> 3.0.3'
  gem 'factory_girl', '~> 4.1.0'
  gem 'tailor', '~> 1.1.2'
  gem 'cane', '~> 2.3.0'
  gem 'codecov'
  gem 'simplecov', :require => false
  gem 'webmock'
  gem 'minitest', '~> 5.3'
  gem 'minitest-reporters'
  gem 'awesome_print', :require => 'ap'
  gem 'nokogiri-diff'
end
