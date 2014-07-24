clean:
	xcodebuild \
		-workspace BZObjectStore.xcworkspace \
		-scheme BZObjectStore \
		clean

test:
	xcodebuild \
		clean \
		test \
		-workspace BZobjectStore.xcworkspace \
		-scheme BZObjectStoreTest \
		-destination "platform=iOS Simulator,name=iPhone Retina (4-inch),OS=7.1" \
		-sdk iphonesimulator \
		-configuration Debug

send-coverage:
	coveralls

