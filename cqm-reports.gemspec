# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "cqm-reports"
  s.summary = "A library for import and export of reports for use with electronic Clinical Quality Measures (eCQMs)."
  s.description = "A library for import and export of reports for use with electronic Clinical Quality Measures (eCQMs)."
  s.email = "tacoma-list@lists.mitre.org"
  s.homepage = "https://github.com/projecttacoma/cqm-reports"
  s.authors = ["The MITRE Corporation"]
  s.license = 'Apache-2.0'

  s.version = '0.0.1'

  s.add_dependency 'mustache'
  s.add_dependency 'cqm-models', '~> 1.0.2'
  s.add_dependency 'cqm-parsers', '~> 0.2.1'

  s.files = Dir.glob('lib/**/*.rb') + Dir.glob('lib/**/*.json') + Dir.glob('lib/**/*.mustache') + Dir.glob('lib/**/*.rake') + ["Gemfile", "README.md", "Rakefile"]
end
