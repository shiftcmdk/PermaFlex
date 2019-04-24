include $(THEOS)/makefiles/common.mk

ARCHS = arm64 arm64e

BUNDLE_NAME = PermaFlexPreferences
PermaFlexPreferences_FILES = PFRootListController.xm PFApp.m PFAppCell.m ../PFFilterManager.xm ../Model/PFFilter.m ../Model/PFProperty.m PFClassesListController.m ../PFFilterTableViewController.m ../PFFilterDetailTableViewController.m ../Cells/PFPropertyCell.m
PermaFlexPreferences_INSTALL_PATH = /Library/PreferenceBundles
PermaFlexPreferences_FRAMEWORKS = UIKit
PermaFlexPreferences_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/PermaFlexPreferences.plist$(ECHO_END)
