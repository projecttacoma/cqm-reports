Gem::Specification.new do |s|
  s.name = "cqm-reports"
  s.summary = "A library for import and export of reports for use with electronic Clinical Quality Measures (eCQMs)."
  s.description = "A library for import and export of reports for use with electronic Clinical Quality Measures (eCQMs)."
  s.email = "tacoma-list@lists.mitre.org"
  s.homepage = "https://github.com/projecttacoma/cqm-reports"
  s.authors = ["The MITRE Corporation"]
  s.license = 'Apache-2.0'

  s.version = '3.1.8'

  s.add_dependency 'cqm-models', '~> 3.0'
  s.add_dependency 'cqm-validators', '~> 3.0'

  s.add_dependency 'mustache'

  s.add_dependency 'erubis', '~> 2.7'
  s.add_dependency 'mongoid-tree', '> 2.0'

  s.add_dependency 'nokogiri', '>= 1.8.5', '< 1.14.0'
  s.add_dependency 'uuid', '~> 2.3'

  s.add_dependency 'zip-zip', '~> 0.3'

  s.add_dependency 'log4r', '~> 1.1'
  s.add_dependency 'memoist', '~> 0.9'

  s.files = Dir.glob('lib/**/*.rb') + Dir.glob('lib/**/*.json') + Dir.glob('lib/**/*.mustache') + Dir.glob('lib/**/*.rake') + ["Gemfile", "README.md", "Rakefile"]
end
