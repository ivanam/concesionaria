ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __dir__)

#Gem::Specification.find_by_name('bundler', '~> 1.17.3').activate
require 'bundler/setup' # Set up gems listed in the Gemfile.
