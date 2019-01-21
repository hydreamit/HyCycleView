Pod::Spec.new do |s|
  s.name         = "HyCycleView"
  s.version      = “0.0.1”
  s.summary      = “cycleView”
  s.homepage     = "https://github.com/hydreamit/HyCycleView"
  s.license      = "MIT"
  s.authors      = { “hy” => “hydreamit@163.com” }
  s.source       = { :git => "https://github.com/hydreamit/HyCycleView.git", :tag => “0.0.1” }
  s.frameworks   = 'Foundation', 'UIKit'
  s.platform     = :ios, '6.0'
  s.source_files = 'HYCycleView/*.{h,m}'
  s.requires_arc = true
end
