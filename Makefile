GO_EASY_ON_ME = 1
ARCHS = armv7 armv7s arm64
include theos/makefiles/common.mk

TWEAK_NAME = SongCount
SongCount_FILES = SongCount.xm

include $(THEOS_MAKE_PATH)/tweak.mk
