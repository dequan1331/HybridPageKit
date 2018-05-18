Pod::Spec.new do |s|
  s.name         = "HybridPageKit"
  s.version      = "0.1"
  s.summary      = "A high-performance、high-extensibility、easy integration framework for Hybrid content page. Support most content page types of News App."
  s.homepage     = "https://github.com/dequan1331/HybridPageKit"
  s.license      = "MIT"
  s.author       = "dequanzhu"
  s.platform     = :ios, "8.0"
  s.requires_arc = true
  s.source       = { :git => "https://github.com/dequan1331/HybridPageKit.git", :tag => "0.1" }
  s.source_files = "HybridPageKit/HybridPageKit/HybridPageKit/ReusableWebView/**/*.{h,m}","HybridPageKit/HybridPageKit/HybridPageKit/HybridViewController/**/*.{h,m}","HybridPageKit/HybridPageKit/HybridPageKit/HybridPageKit.h"
  s.public_header_files = "HybridPageKit/HybridPageKit/HybridPageKit/HybridPageKit.h","HybridPageKit/HybridPageKit/HybridPageKit/HybridViewController/HPKViewConfig.h","HybridPageKit/HybridPageKit/HybridPageKit/HybridViewController/HPKAbstractViewController.h","HybridPageKit/HybridPageKit/HybridPageKit/HybridViewController/HPKDefs.h"

  s.subspec 'WKWebViewExtension' do |ss|
      ss.source_files = 'HybridPageKit/HybridPageKit/HybridPageKit/WKWebViewExtensions/**/*.{h,m}'
  end

  s.subspec 'ScrollReuseHandler' do |ss|
      ss.source_files = 'HybridPageKit/HybridPageKit/HybridPageKit/ScrollReuseHandler/**/*.{h,m}'
  end
end