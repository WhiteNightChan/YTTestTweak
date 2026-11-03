TARGET := iphone:clang:latest:14.0
ARCHS = arm64
INSTALL_TARGET_PROCESSES = YouTube
THEOS_PACKAGE_SCHEME = rootless
FINALPACKAGE = 1

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = YTTestTweak

$(TWEAK_NAME)_FILES = $(shell find Sources -type f \( -name "*.x" -o -name "*.m" \))
$(TWEAK_NAME)_CFLAGS = -fobjc-arc -ISources -DPACKAGE_VERSION='@"$(shell grep '^Version:' control | cut -d' ' -f2)"'
$(TWEAK_NAME)_FRAMEWORKS = UIKit Foundation

include $(THEOS_MAKE_PATH)/tweak.mk
