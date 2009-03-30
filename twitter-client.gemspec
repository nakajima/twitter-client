# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{twitter-client}
  s.version = "0.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Pat Nakajima"]
  s.date = %q{2009-03-30}
  s.email = %q{patnakajima@gmail.com}
  s.files = ["lib/core_ext", "lib/core_ext/delegation.rb", "lib/twitter", "lib/twitter/api.rb", "lib/twitter/connection.rb", "lib/twitter/session.rb", "lib/twitter-client.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/nakajima/twitter-client}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Simple, clean, redundant.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      # s.add_runtime_dependency(%q<nakajima-nakajima>, [">= 0"])
    else
      # s.add_dependency(%q<nakajima-nakajima>, [">= 0"])
    end
  else
    # s.add_dependency(%q<nakajima-nakajima>, [">= 0"])
  end
end
