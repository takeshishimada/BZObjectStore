WORKSPACE = BZObjectStore.xcworkspace
SCHEME = BZObjectStore

clean:
	xcodebuild \
		-workspace $(WORKSPACE) \
		-scheme $(SCHEME) \
		clean

test:
	xcodebuild \
		-workspace $(WORKSPACE) \
		-scheme $(SCHEME) \
		-sdk iphonesimulator \
		-configuration Debug \
		TEST_AFTER_BUILD=YES \
		TEST_HOST= 

