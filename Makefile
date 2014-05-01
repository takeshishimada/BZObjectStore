WORKSPACE = BZObjectStore.xcworkspace
SCHEME = BZObjectStore

clean:
	xcodebuild \
		-workspace $(WORKSPACE) \
		-scheme $(SCHEME) \
		clean

test
	xcodebuild \
		-workspace $(WORKSPACE) \
		-scheme $(SCHEME) \
		-sdk iphonesimulator7.1 \
		-configuration Debug \
		TEST_AFTER_BUILD=YES \
		TEST_HOST= 

