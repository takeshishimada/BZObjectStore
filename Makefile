clean:
	xcodebuild \
		-workspace BZObjectStore.xcworkspace \
		-scheme BZObjectStore \
		clean

test:
	xcodebuild \
		clean \
		build \
		test \
		-workspace BZobjectStore.xcworkspace \
		-scheme BZObjectStore \
		-destination "platform=iOS Simulator,name=iPhone Retina (4-inch),OS=7.1" \
		-sdk iphonesimulator \
		OBJROOT=build \
		-configuration Debug

send-coverage:
	coveralls \
		-e BZObjectStoreTest/Tests
