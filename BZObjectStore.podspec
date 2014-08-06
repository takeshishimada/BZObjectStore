Pod::Spec.new do |s|
  s.name     = 'BZObjectStore'
  s.version  = '1.3.11'
  s.license  = 'MIT'
  s.summary  = 'ORM library wrapped FMDB'
  s.homepage = 'https://github.com/expensivegasprices/BZObjectStore'
  s.author   = { "BONZOO LLC" => "expensivegasprices@gmail.com" }
  s.source   = { :git => 'https://github.com/expensivegasprices/BZObjectStore.git', :tag => s.version.to_s }
  s.ios.deployment_target = '5.0'
  s.osx.deployment_target = '10.8'
  s.requires_arc = true

  s.default_subspec = 'Core'

  s.subspec 'Core' do |cs|
    cs.dependency 'FMDB'
    cs.dependency 'BZRuntime'
    cs.dependency 'AutoCoding'
    cs.source_files = 'BZObjectStore/Core/**/*.{h,m}'
  end

  s.subspec 'CoreLocation' do |ps|
    ps.dependency 'BZObjectStore/Core'
    ps.framework    = 'CoreLocation'
    ps.source_files = 'BZObjectStore/CoreLocation/*.{h,m}'
  end

  s.subspec 'ActiveRecord' do |ps|
    ps.dependency 'BZObjectStore/Core'
    ps.source_files = 'BZObjectStore/ActiveRecord/*.{h,m}'
  end

  s.subspec 'Parse' do |ps|
    ps.ios.deployment_target = '5.0'
    ps.ios.dependency 'BZObjectStore/Core'
    ps.ios.dependency 'Parse-iOS-SDK'
    ps.ios.framework    = 'Parse'
    ps.ios.xcconfig = { 'FRAMEWORK_SEARCH_PATHS' => '"$(PODS_ROOT)/Parse"' }
    ps.ios.source_files = 'BZObjectStore/BZObjectStoreParse/*.{h,m}'
    ps.osx.deployment_target = '10.8'
    ps.osx.dependency 'BZObjectStore/Core'
    ps.osx.dependency 'Parse-OSX-SDK'
    ps.osx.framework    = 'ParseOSX'
    ps.osx.xcconfig = { 'FRAMEWORK_SEARCH_PATHS' => '"$(PODS_ROOT)/Parse"' }
    ps.osx.source_files = 'BZObjectStore/BZObjectStoreParse/*.{h,m}'
 end

end
