PLATFORM := $(shell uname -s)
ifneq ($(findstring MINGW,$(PLATFORM)),)
PLATFORM := windows32
USE_WINDRES := true
endif

ifneq ($(findstring MSYS,$(PLATFORM)),)
PLATFORM := windows32
endif

ifeq ($(PLATFORM),windows32)
# To force use of the Unix version instead of the Windows version
MKDIR := $(shell which mkdir)
else
MKDIR := mkdir
endif

NULL := /dev/null
ifeq ($(PLATFORM),windows32)
NULL := NUL
endif

all: gamevoy

gamevoy: $(shell find . -type f -name '*.v') bootroms/dmg_boot.bin bootroms/cgb_boot.bin
	v -w .

bootroms/%.bin: bootroms/%.asm bootroms/CGB_logo.pb12
	-@$(MKDIR) -p $(dir $@)
	rgbasm -i bootroms -o $@.tmp $<
	rgblink -o $@.tmp2 $@.tmp
	dd if=$@.tmp2 of=$@ count=1 bs=$(if $(findstring dmg,$@)$(findstring sgb,$@)$(findstring mgb,$@),256,2304) 2> $(NULL)
	@rm $@.tmp $@.tmp2

bootroms/%.2bpp: bootroms/%.png
	-@$(MKDIR) -p $(dir $@)
	rgbgfx $(if $(filter $(shell echo 'print __RGBDS_MAJOR__ || (!__RGBDS_MAJOR__ && __RGBDS_MINOR__ > 5)' | rgbasm -), $$0), -h -u, -Z -u -c embedded) -o $@ $<

bootroms/%.pb12: bootroms/%.2bpp bootroms/pb12.vsh
	-@$(MKDIR) -p $(dir $@)
	v run bootroms/pb12.vsh < $< > $@

clean:
	$(RM) gamevoy
	$(RM) bootroms/*.bin
	$(RM) bootroms/*.pb12

.PHONY: all clean
