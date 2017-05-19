# encoding: UTF-8

Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'solidus_talon_one'
  s.version     = '1.0.0'
  s.summary     = 'Solidus Plug-In for the Talon.One Promotion Engine'
  s.required_ruby_version = '>= 2.1'
  s.date	= '2017-05-19'

  s.author    = 'Talon.One GmbH'
  s.email     = 'devs@talon.one'
  s.homepage  = 'https://github.com/talon-one/plugin-solidus'
  s.license   = %q{MIT}

  s.files       = `git ls-files`.split("\n")
  s.require_paths = ['lib']
  s.requirements << 'none'

  s.add_dependency 'solidus', ['>= 1.2.0.alpha', '< 1.3.0']
  s.add_dependency 'talon_one', ['0.0.5']
end
