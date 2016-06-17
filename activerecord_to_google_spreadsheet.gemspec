# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'activerecord_to_google_spreadsheet/version'

Gem::Specification.new do |spec|
  spec.name          = "activerecord_to_google_spreadsheet"
  spec.version       = ActiverecordToGoogleSpreadsheet::VERSION
  spec.authors       = ["Otis Chen"]
  spec.email         = ["kkooff2000@gmail.com"]

  spec.summary       = %q{ActiveRecord to Google SpreadSheets.}
  spec.description   = %q{Dump databases to Google SpreadSheets and can also from SpreadSheets.}
  spec.homepage      = "https://github.com/kkooff2000/activerecord_to_google_spreadsheet"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
end
