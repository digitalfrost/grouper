# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "grouper"
  s.version     = "0.0.1"
  s.authors     = ["digitalfrost"]
  s.email       = ["it@leanbid.com"]
  s.homepage    = "https://github.com/digitalfrost/grouper"
  s.summary     = "Super Easy AWS Security Group Management"
  s.description = "Easily configure and manage Amazon Web Services Security Groups"
  s.files       = ["lib/grouper.rb"]
  s.add_dependency('aws-sdk')
  s.license = "MIT"

  s.rubyforge_project = "grouper"

  
end
