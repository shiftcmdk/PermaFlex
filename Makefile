include $(THEOS)/makefiles/common.mk

TWEAK_NAME = PermaFlex
PermaFlex_FILES = Tweak.xm PFFilterTableViewController.m PFFilterDetailTableViewController.m Cells/PFPropertyCell.m Model/PFProperty.m Model/PFFilter.m PFFilterManager.xm

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += permaflexpreferences
include $(THEOS_MAKE_PATH)/aggregate.mk
