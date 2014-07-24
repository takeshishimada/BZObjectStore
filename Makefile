clean:
	xcodebuild \
		-workspace BZObjectStore.xcworkspace \
		-scheme BZObjectStore \
		clean

test:
	xcodebuild \
		test \
		-workspace BZobjectStore.xcworkspace \
		-scheme BZObjectStoreTests \
		-destination "platform=iOS Simulator,name=iPhone Retina (4-inch),OS=7.1" \
		-sdk iphonesimulator \
		-configuration Debug \
		OBJROOT=build
