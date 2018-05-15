PROJECT_NAME = Kaze

TWEAK_NAME = $(PROJECT_NAME)
BUNDLE_NAME = $(PROJECT_NAME)Preferences

$(PROJECT_NAME)_FILES = $(wildcard src/*.m)
$(PROJECT_NAME)_FRAMEWORKS = UIKit
$(PROJECT_NAME)_PRIVATE_FRAMEWORKS = BaseBoardUI FrontBoard BackBoardServices
$(PROJECT_NAME)_INSTALL_PATH = /Library/MobileSubstrate/DynamicLibraries

$(PROJECT_NAME)Preferences_FILES = $(wildcard pref/*.m)
$(PROJECT_NAME)Preferences_RESOURCE_DIRS = res
$(PROJECT_NAME)Preferences_FRAMEWORKS = UIKit Social
$(PROJECT_NAME)Preferences_PRIVATE_FRAMEWORKS = Preferences
$(PROJECT_NAME)Preferences_INSTALL_PATH = /Library/PreferenceBundles

export TARGET = iphone:clang # simulator:clang
export ARCHS = armv7s arm64 # x86_64
export TARGET_IPHONEOS_DEPLOYMENT_VERSION = 9.0
export ADDITIONAL_OBJCFLAGS = -fobjc-arc -fvisibility=hidden
export ADDITIONAL_LDFLAGS = -Flib
export INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)pref="$(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences"; mkdir -p "$$pref"; cp $(PROJECT_NAME)Preferences.plist "$$pref/$(PROJECT_NAME).plist"$(ECHO_END)
	@(echo "Generating localization resources..."; twine generate-all-localization-files loc/strings.txt "$(THEOS_STAGING_DIR)/$($(PROJECT_NAME)Preferences_INSTALL_PATH)/$(PROJECT_NAME)Preferences.bundle" --create-folders --format apple)

simulator: all
	xcrun simctl spawn booted launchctl debug system/com.apple.SpringBoard --environment DYLD_INSERT_LIBRARIES=$(THEOS_OBJ_DIR)/$(PROJECT_NAME).dylib
	xcrun simctl spawn booted launchctl stop com.apple.SpringBoard
