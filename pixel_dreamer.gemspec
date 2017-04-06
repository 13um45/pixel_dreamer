# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pixel_dreamer/version'

Gem::Specification.new do |spec|
  spec.name          = "pixel_dreamer"
  spec.version       = PixelDreamer::VERSION
  spec.authors       = ["Christian Samuel"]
  spec.email         = ["christian.leumas@icloud.com"]

  spec.summary       = %q{A wrapper for pxlsrt, adds settings and gif creation.}
  spec.description   = %q{Create pixel sorted gifs.}
  spec.homepage      = "https://github.com/13um45/pixel_dreamer"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'rmagick', '~> 2.16.0'
  spec.add_runtime_dependency 'pxlsrt', '~> 1.8.2'
  spec.add_runtime_dependency 'image_optim', '~> 0.24.0'
  spec.add_runtime_dependency 'image_optim_pack', '~> 0.3.0.20161108'

  spec.add_development_dependency 'bundler', '~> 1.13'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'simplecov', '~> 0.12.0'
end
