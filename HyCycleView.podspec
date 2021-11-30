Pod::Spec.new do |s|
s.name         = 'HyCycleView'
s.version      = '1.0.7'
s.summary      = 'HyCycleView HyCyclePageView HySegmentView'
s.homepage     = 'https://github.com/hydreamit/HyCycleView'
s.license      = 'MIT'
s.authors      = {'Hy' => 'hydreamit@163.com'}
s.platform     = :ios, '9.0'
s.source       = {:git => 'https://github.com/hydreamit/HyCycleView.git', :tag => s.version}
s.source_files = 'HyCycleView/**/*.{h,m}'
s.framework    = 'UIKit'
s.requires_arc = true
end
