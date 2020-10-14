require_relative 'lib/simple/mu/application/version'

Gem::Specification.new do |spec|
  spec.name          = "simple-mu-application"
  spec.version       = Simple::Mu::Application::VERSION
  spec.authors       = ["redj.ai"]
  spec.email         = ["info@redj.ai"]

  spec.summary       = %q{microservice application for the redj.ai mu framework}
  spec.description   = %q{microservice application for the redj.ai mu frameworke.}
  spec.homepage      = "https://redj.ai"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.add_development_dependency "rake", "~> 12.0"
  spec.add_development_dependency "climate_control"
  spec.add_development_dependency "rspec", "~> 3.0"

  spec.add_runtime_dependency "aws-sdk-sns"

  #spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/redjai/simple-mu-application"
  spec.metadata["changelog_uri"] = "https://github.com/redjai/simple-mu-application/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
end
