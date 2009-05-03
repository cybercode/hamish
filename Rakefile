require 'rubygems'

begin
  require 'rake'
  require 'rake/gempackagetask'
rescue LoadError
  puts 'This script should only be accessed via the "rake" command.'
  puts 'Installation: gem install rake -y'
  exit
end
require 'rake/clean'

PKG_NAME    = "Hamish"
PKG_VERSION = '0.1'
AUTHORS     = 'Rick Frankel'
EMAIL       = 'hamish@rickster.com'
SUMMARY     = 'A mildly opinionated static site generator'

spec = Gem::Specification.new do |s|
  s.name                  = PKG_NAME
  s.version               = PKG_VERSION
  s.authors               = AUTHORS
  s.email                 = EMAIL
  # s.homepage            = HOMEPAGE
  # s.rubyforge_project   = PKG_NAME
  s.summary               = SUMMARY
  s.description           = s.summary
  #s.platform              = Gem::Platform::RUBY
  s.require_path          = 'lib'
  # s.executables           = []
  s.files                 = %w[Rakefile README.markdown] + 
    Dir['{lib,test}/**/*']
  s.test_files            = []
  # s.has_rdoc            = true
  # s.extra_rdoc_files    = RDOC_FILES
  # s.rdoc_options        = RDOC_OPTIONS
  # s.required_ruby_version = ">= 1.8.4"
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.gem_spec = spec
  #pkg.need_tar = true
end
