WORKSPACE = BZObjectStore.xcworkspace
SCHEME = BZObjectStore
TEST_TARGET = BZObjectStoreTests

clean:
	xcodebuild -workspace BZObjectStore.xcworkspace -scheme BZObjectStore clean

test:
	xcodebuild \
		-workspace $(WORKSPACE) \
		-scheme $(SCHEME) \
		-target $(TEST_TARGET) \
		-sdk iphonesimulator \
		-configuration Debug \
		TEST_AFTER_BUILD=YES \
		TEST_HOST=

test-with-coverage:
	xcodebuild \
		-workspace $(WORKSPACE) \
		-scheme $(SCHEME) \
		-target $(TEST_TARGET) \
		-sdk iphonesimulator \
		-configuration Debug \
		TEST_AFTER_BUILD=YES \
		TEST_HOST= \
		GCC_INSTRUMENT_PROGRAM_FLOW_ARCS=YES \
		GCC_GENERATE_TEST_COVERAGE_FILES=YES

send-coverage:
	coveralls \
		-e BZObjectStoreTests
