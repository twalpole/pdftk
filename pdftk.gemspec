Gem::Specification.new do |s|
  s.name        = 'pdftk'
  s.version     = '0.1.0'
  s.summary     = 'Ruby wrapper around pdftk (a handy tool for manipulating PDF)'
  s.description = 'Ruby wrapper around pdftk (a handy tool for manipulating PDF)'
  s.files       = Dir['lib/**/*.rb']
  s.author      = 'remi'
  s.email       = 'remi@remitaylor.com'
  s.homepage    = 'http://github.com/remi/pdftk'

  s.add_dependency 'haml', '>= 3.1'
  s.add_development_dependency('rspec', [">=2.2.0"])
end
