Pod::Spec.new do |s|
  s.name         = "HybridPageKit"
  s.version      = "1.4"
  s.summary      = "A high-performance、high-extensibility、easy integration framework for Hybrid content page. Support most content page types of News App."
  s.homepage     = "https://github.com/dequan1331/HybridPageKit"
  s.license      = "MIT"
  s.author       = "dequanzhu"
  s.platform     = :ios, "8.0"
  s.requires_arc = true
  s.source       = { :git => "https://github.com/dequan1331/HybridPageKit.git", :tag => s.version.to_s }
  s.source_files = "HybridPageKit/HybridPageKit/HybridPageKit/**/*.{h,m}"
  s.public_header_files = "HybridPageKit/HybridPageKit/HybridPageKit/*.h"

  s.test_spec 'HybridPageKitTests' do |test_spec|
    test_spec.source_files = "HybridPageKit/HybridPageKit/HybridPageKitTests/*.{h,m}"
  end 
end