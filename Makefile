include $(THEOS)/makefiles/common.mk

TWEAK_NAME = reFLEX
reFLEX_FILES = Tweak.xm $(wildcard FLEX/*.m)
reFLEX_FRAMEWORKS = UIKit CoreGraphics ImageIO QuartzCore CoreFoundation
reFLEX_LIBRARIES = sqlite3 z activator
reFLEX_CFLAGS += -fobjc-arc -w

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
