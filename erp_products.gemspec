$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "erp/products/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "erp_products"
  s.version     = Erp::Products::VERSION
  s.authors     = ["Nguyen Ton Hung"]
  s.email       = ["1633514@hcmut.edu.vn"]
  s.homepage    = "http://hcmut.edu.vn/"
  s.summary     = "Products features."
  s.description = "Products features."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails"
  s.add_dependency "erp_core"
  s.add_dependency "deface"
end
