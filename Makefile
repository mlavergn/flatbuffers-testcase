###############################################
#
# Makefile
#
###############################################

.DEFAULT_GOAL := compile

###############################################

SDK := macosx.internal
SDKROOT := $(shell xcode-select -p)/Platforms/MacOSX.platform/Developer/SDKs/MacOSX14.0.Internal.sdk
INCLUDE_PATH := ${SDKROOT}/usr/local/include
FRAMEWORK_PATH := ${SDKROOT}/System/Library/PrivateFrameworks

env:
	@echo ${SDKROOT}

help:
	xcrun --sdk ${SDK} flatc --objc-apple -help

st:
	open -a SourceTree .

#
# ----- -OBJC-----
#

__SRCS := Demo.mm Demo_mutable_generated.o Demo_immutable_generated.o

__flatc: clean
	xcrun --sdk ${SDK} flatc --objc --objc-prefix DM_ -o objc Demo.fbs
	xcrun clang++ -c -ObjC++ objc/Demo_mutable_generated.mm -fno-caret-diagnostics -fno-diagnostics-show-option -fmessage-length=0 --std=c++17 -stdlib=libc++ -isysroot ${SDKROOT} 
	xcrun clang++ -c -ObjC++ objc/Demo_immutable_generated.mm -fno-caret-diagnostics -fno-diagnostics-show-option -fmessage-length=0 --std=c++17 -stdlib=libc++ -isysroot ${SDKROOT} 

__objc:
	xcrun clang++ -ObjC++ -lc++ -o demo ${__SRCS} -DOBJC_APPLE=0 -fno-caret-diagnostics -fno-diagnostics-show-option -fmessage-length=0 --std=c++17 -stdlib=libc++ -isysroot ${SDKROOT} -Iobjc -I${INCLUDE_PATH} -framework Foundation

__compile: __flatc __objc
	./demo

#
# ----- -OBJC-APPLE -----
#

_SRCS := Demo.mm Demo_generated.o

_flatc: clean
	xcrun --sdk ${SDK} flatc --objc-apple -o objc Demo.fbs
	xcrun clang++ -c -ObjC++ objc/Demo_generated.mm -fno-caret-diagnostics -fno-diagnostics-show-option -fmessage-length=0 --std=c++17 -stdlib=libc++ -isysroot ${SDKROOT} -F${FRAMEWORK_PATH}

_objc:
	xcrun clang++ -ObjC++ -lc++ -o demo ${_SRCS} -DOBJC_APPLE=1 -fno-caret-diagnostics -fno-diagnostics-show-option -fmessage-length=0 --std=c++17 -stdlib=libc++ -isysroot ${SDKROOT} -Iobjc -I${INCLUDE_PATH} -framework Foundation -framework AppleFlatBuffers -F${FRAMEWORK_PATH}

_compile: _flatc _objc
	./demo

#
# Combined
#

compile: _compile
	@echo "done"

clean:
	rm -f demo
	rm -f *.o
	rm -rf objc