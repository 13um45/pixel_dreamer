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
  spec.homepage      = "https://github.com/13um45/pixel_dreamer"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'rmagick'
  spec.add_runtime_dependency 'pxlsrt'
  spec.add_runtime_dependency 'image_optim'
  spec.add_runtime_dependency 'image_optim_pack'

  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'simplecov'
end
