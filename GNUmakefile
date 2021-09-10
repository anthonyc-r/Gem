include $(GNUSTEP_MAKEFILES)/common.make


# Application
VERSION = 0.4
PACKAGE_NAME = Gem
APP_NAME = Gem
Gem_APPLICATION_ICON = Gemas.tiff

# Languages
Gem_LANGUAGES = \
  English \
  Spanish

Gem_LOCALIZED_RESOURCE_FILES = \
Gem.gorm \
Editor.gorm \
Preferences.gorm \
GoToLine.gorm \
Localizable.strings

# Resource files
Gem_RESOURCE_FILES = \
Resources/Gemas.tiff \
Resources/Gem.tiff \
Resources/Gemas.ico \
Resources/Gem.ico \
Resources/FileIcon_.c.tiff \
Resources/FileIcon_.cc.tiff \
Resources/FileIcon_.gsmarkup.tiff \
Resources/FileIcon_.h.tiff \
Resources/FileIcon_.m.tiff \
Resources/FileIcon_.mm.tiff \
Resources/FileIcon_.plist.tiff \
Resources/FileIcon_.strings.tiff \
Resources/FileIcon_.java.tiff \
Resources/FileIcon_.qc.tiff \
Resources/FileIcon_.glsl.tiff \
Resources/FileIcon_.mat.tiff \
Resources/FileIcon_.shader.tiff \
Resources/FileIcon_.script.tiff \
Resources/FileIcon_txt.tiff \
Resources/FileIcon_makefile.tiff \
Resources/nonEnglishCharacters.plist \
Resources/AppResources \
Resources/ToolResources \
Resources/words.plist


# Header files
Gem_HEADER_FILES = \
GemasController.h \
GemasEditorView.h \
GemasDocument.h \
EditorWindow.h \
Preferences.h \
InputModifiers/ObjcAutoIndenter.h \
InputModifiers/InputModifiable.h 


# Class files
Gem_OBJC_FILES = \
GemasController.m \
GemasEditorView.m \
GemasDocument.m \
EditorWindow.m \
Preferences.m \
InputModifiers/ObjcAutoIndenter.m


# Other sources
Gem_OBJC_FILES += \
Gemas_main.m

ADDITIONAL_FLAGS += -std=gnu99

# Makefiles
-include GNUmakefile.preamble
include $(GNUSTEP_MAKEFILES)/aggregate.make
include $(GNUSTEP_MAKEFILES)/application.make
-include GNUmakefile.postamble
