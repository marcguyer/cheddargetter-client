# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{cheddargetter-client}
  s.version = "0.2.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Marc Guyer"]
  s.date = %q{2009-07-30}
  s.email = %q{marc@cheddargetter.com}
  s.extra_rdoc_files = [
    "LICENSE",
     "README.rdoc"
  ]
  s.files = [
    ".document",
     ".gitignore",
     "LICENSE",
     "README.rdoc",
     "Rakefile",
     "VERSION.yml",
     "cheddargetter-client.gemspec",
     "lib/cheddargetter-client.rb",
     "test/cheddargetter-client_test.rb",
     "test/test_helper.rb"
  ]
  s.homepage = %q{http://github.com/marcguyer/cheddargetter-client}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{CheddarGetter Client is a wrapper for the CheddarGetter API}
  s.test_files = [
    "test/cheddargetter-client_test.rb",
     "test/test_helper.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
