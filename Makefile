WORKSPACE = BZObjectStore.xcworkspace
SCHEME = BZObjectStore

clean:
	xcodebuild \
		-workspace $(WORKSPACE) \
		-scheme $(SCHEME) \
		clean

test-with-coverage:
	xcodebuild \
		-workspace $(WORKSPACE) \
		-scheme $(SCHEME) \
		-sdk iphonesimulator7.1 \
		-configuration Debug \
		TEST_AFTER_BUILD=YES \
		TEST_HOST= \
		GCC_INSTRUMENT_PROGRAM_FLOW_ARCS=YES \
		GCC_GENERATE_TEST_COVERAGE_FILES=YES build test

send-coverage:
	coveralls \
		-e BZObjectStoreTests