source 'https://github.com/CocoaPods/Specs.git'

inhibit_all_warnings!

def import_pods
	pod 'FMDB'
	pod 'BZRuntime'
	pod 'AutoCoding'
	pod 'Bolts', :inhibit_warnings => true
	pod 'TKRGuard'
end

target :ios do
	platform :ios, '6.0'
	link_with 'BZObjectStore', 'BZObjectStoreTests'
	import_pods
	pod 'Parse'
end

target :osx do
	platform :osx, '10.8'
	link_with 'BZObjectStoreMAC', 'BZObjectStoreTests'
	import_pods
	pod 'Parse-OSX'
end