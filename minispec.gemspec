# coding: utf-8

name, version = 'minispec 0.0.2'.split
Gem::Specification.new do |spec|
  spec.name          = name
  spec.version       = version
  spec.authors       = ['Slee Woo']
  spec.email         = ['mail@sleewoo.com']
  spec.description   = 'Simple, Intuitive, Full-featured Testing Framework'
  spec.summary       = [name, version]*'-'
  spec.homepage      = 'https://github.com/sleewoo/' + name
  spec.license       = 'MIT'

  spec.files = Dir['**/{*,.[a-z]*}'].reject {|e| e =~ /\.(gem|lock)\Z/}
  spec.require_paths = ['lib']

  spec.executables = Dir['bin/*'].map{|f| File.basename(f)}

  spec.required_ruby_version = '>= 1.9.2'

  spec.add_dependency 'diff-lcs', '~> 1'
  spec.add_dependency 'coderay',  '~> 1'

  spec.add_development_dependency 'minitest', '~> 5'
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
end
