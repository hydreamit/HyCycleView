Pod::Spec.new do |s|
  s.name         = "HYCycleView"
  s.version      = "0.0.1"
  s.summary      = “可自定义的广告轮播”
  s.homepage     = "https://github.com/hydreamit/HYCycleView"
  s.license      = "MIT"
  s.author       = { "hy" => "735342336@qq.com" }
  s.source       = { :git => "https://github.com/hydreamit/HYCycleView.git”, :tag => s.version.to_s }
  s.frameworks   = 'Foundation', 'UIKit'
  s.platform     = :ios, ‘8.0’
  s.source_files  = "Classes", "Classes/**/*.{h,m}"
  s.exclude_files = "Classes/Exclude"
  s.source_files = 'HYCycleView/**/*.{h,m}'
  s.requires_arc = true
end
