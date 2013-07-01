require 'rake'

Gem::Specification.new do |s|
  s.name = 'dohmysql'
  s.version = '0.2.34'
  s.summary = 'friendly mysql client interface'
  s.description = 'wrapper classes around low level mysql gem to provide a better interface'
  s.require_path = 'lib'
  s.required_ruby_version = '>= 1.9.3'
  s.add_runtime_dependency 'dohroot', '>= 0.1.2'
  s.add_runtime_dependency 'dohutil', '>= 0.2.15'
  s.add_runtime_dependency 'dohlog', '>= 0.2.4'
  s.add_runtime_dependency 'mysql2', '>= 0.3.11'
  s.add_runtime_dependency 'sqlstmt', '>= 0.1.14'
  s.add_development_dependency 'dohtest', '>= 0.1.24'
  s.authors = ['Makani Mason', 'Kem Mason']
  s.bindir = 'bin'
  s.homepage = 'https://github.com/atpsoft/dohmysql'
  s.license = 'MIT'
  s.email = ['devinfo@atpsoft.com']
  s.extra_rdoc_files = ['MIT-LICENSE']
  s.test_files = FileList["{test}/**/*.rb"].to_a
  s.executables = FileList["{bin}/**/*"].to_a.collect { |elem| elem.slice(4..-1) }
  s.files = FileList["{bin,lib,test}/**/*"].to_a
end
