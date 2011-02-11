# -*- encoding: utf-8 -*-
require File.expand_path("../lib/neutrino/version", __FILE__)

Gem::Specification.new do |s|
  s.name        = "neutrino_client"
  s.version     = Neutrino::Client::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Nick Stielau"]
  s.email       = ["nick.stielau+neutrino@gmail.com"]
  s.homepage    = "http://rubygems.org/gems/neutrino_client"
  s.summary     = "A client for sending metrics to Neutrino."
  s.description = "A client for sending metrics to Neutrino."

  s.required_rubygems_version = ">= 1.3.6"
  s.rubyforge_project         = "neutrino_client"

  s.add_development_dependency "bundler", ">= 1.0.0"
  s.add_development_dependency "mocha", ">= 0.9.11"
  s.add_development_dependency "fakeweb", ">= 1.3.0"

  s.add_dependency "mixlib-config", ">= 1.1.2"
  s.add_dependency "mixlib-cli", ">= 1.2.0"
  s.add_dependency "json_pure", ">= 1.4.6"
  s.add_dependency "hashie", ">= 1.0.0"
  s.add_dependency "httparty", ">= 0.5.3"

  s.files        = `git ls-files`.split("\n")
  s.executables  = `git ls-files`.split("\n").map{|f| f =~ /^bin\/(.*)/ ? $1 : nil}.compact
  s.require_path = 'lib'
end
