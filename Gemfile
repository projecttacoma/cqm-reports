source 'https://rubygems.org'

gemspec :development_group => :test

gem 'protected_attributes_continued'

group :development, :test do
  gem 'bundler-audit'
  gem 'rubocop', '~> 0.93.0', require: false
end

group :development do
  gem 'rake'
  gem 'byebug'
end

group :test do
  gem 'cqm-models', '~> 4.0'
  gem 'tailor', '~> 1.1.2'
  gem 'cane', '~> 2.3.0'
  gem 'codecov'
  gem 'simplecov', :require => false
  gem 'simplecov-cobertura'
  gem 'webmock'
  gem 'minitest', '~> 5.3'
  gem 'minitest-reporters'
  gem 'awesome_print', :require => 'ap'
  gem 'nokogiri-diff'
end
