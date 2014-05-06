Pod::Spec.new do |s|
  s.name     = 'BZObjectStore'
  s.version  = '1.0.5'
  s.license  = 'MIT'
  s.summary  = 'ORM library wrapped FMDB'
  s.homepage = 'https://github.com/expensivegasprices/BZObjectStore'
  s.author   = { "BONZOO LLC" => "expensivegasprices@gmail.com" }
  s.source   = { :git => 'https://github.com/expensivegasprices/BZObjectStore.git', :tag => s.version.to_s }
  s.platform = :ios, '5.0'
  s.requires_arc = true
  s.source_files = 'BZObjectStore/BZObjectStore/**/*.{h,m}'
  
  s.dependency 'FMDB'
  s.dependency 'ColorUtils'
  s.dependency 'BZRuntime'

  s.subspec 'Parse' do |ss|
    ss.dependency 'FMDB'
    ss.dependency 'Parse'
    ss.framework    = 'Parse'
    ss.ios.xcconfig = { 'FRAMEWORK_SEARCH_PATHS' => '"$(PODS_ROOT)/Parse"' }
    ss.source_files = 'BZObjectStore/BZObjectStore/**/*.{h,m}','BZObjectStore/BZObjectStoreParse/*.{h,m}'
  end

end
