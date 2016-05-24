CMySQL=CMySQL-1.0.0
BUILDOPTS=-Xlinker -L/usr/lib -Xcc -IPackages/$(CMySQL)

SWIFTC=swiftc
SWIFT=swift
ifdef SWIFTPATH
    SWIFTC=$(SWIFTPATH)/bin/swiftc
    SWIFT=$(SWIFTPATH)/bin/swift
endif
OS := $(shell uname)
ifeq ($(OS),Darwin)
    SWIFTC=xcrun -sdk macosx swiftc
	BUILDOPTS=-Xcc -IPackages/$(CMySQL) -Xlinker -L/usr/local/lib -Xcc -I/usr/local/include/mysql  -Xcc -I/usr/local/include
endif

XCODEOPTS=-Xcc -I/usr/local/include -Xcc -I/usr/local/include/mysql -Xswiftc -I/usr/local/include/mysql -Xswiftc -I/usr/local/include -Xlinker -L${CURDIR}/.build/debug/ -Xlinker -L/usr/local/lib -X

buildv:
	@echo "Building..."
	swift build -v > log.txt

build:
	@echo "Building..."
	$(SWIFT) build $(BUILDOPTS) > log.txt

run: build
	@echo "Run Executtable ctrl-c to quit"
	export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$(pwd)/.build/debug
	.build/debug/SimpleMySQLClassGenerator
xcode: build
		swift build $(XCODEOPTS)
clean:
	rm -rf .build Packages
