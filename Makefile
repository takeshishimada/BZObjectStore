test:
	xcodebuild \
		clean \
		test \
		-workspace BZobjectStore.xcworkspace \
		-scheme BZObjectStore \
		-destination "platform=iOS Simulator,name=iPhone Retina (4-inch),OS=7.1" \
		-sdk iphonesimulator \
		-configuration Debug \
		OBJROOT=build
