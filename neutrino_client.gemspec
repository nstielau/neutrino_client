# -*- encoding: utf-8 -*-
require File.expand_path("../lib/neutrino_client/version", __FILE__)

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

  s.files        = `git ls-files`.split("\n")
  s.executables  = `git ls-files`.split("\n").map{|f| f =~ /^bin\/(.*)/ ? $1 : nil}.compact
  s.require_path = 'lib'
end
