# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "podnix/api/version"

Gem::Specification.new do |s|
  s.name        = "podnix"
  s.version     = Podnix::API::VERSION
  s.authors     = ["Kishorekumar Neelamegam, Thomas Alrin, Rajthilak"]
  s.email       = ["nkishore@megam.co.in","alrin@megam.co.in", "rajthilak@megam.co.in"]
  s.homepage    = "http://github.com/indykish/podnix.rb"
  s.license = "Apache V2"
  s.extra_rdoc_files = ["README.md", "LICENSE" ]
  s.summary     = %q{Ruby Client for the Podnix Cloud}
  s.description = %q{Ruby Client for the Podnix Cloud. Performs REST based HTTP calls to https://api.podnix.com }
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  s.add_runtime_dependency 'excon'
  s.add_runtime_dependency 'highline'
  s.add_runtime_dependency 'yajl-ruby'
  s.add_runtime_dependency 'multi_json'
  s.add_development_dependency 'minitest'
  s.add_development_dependency 'rake'
end
