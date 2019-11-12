IASL=iasl
TARGET?=NUC-Hades-Canyon

DEFINES=-DTARGET=$(TARGET)
ifneq ($(SSDT_NAME),)
DEFINES+=-DSSDT_NAME=\"$(SSDT_NAME)\"
endif
ifneq ($(NO_WINDOWS_SUPPORT),)
DEFINES+=-DNO_WINDOWS_SUPPORT=$(NO_WINDOWS_SUPPORT)
endif
ifneq ($(TBT_HOTPLUG_GPE),)
DEFINES+=-DTBT_HOTPLUG_GPE=$(TBT_HOTPLUG_GPE)
endif
ifneq ($(TBT_ROOT),)
DEFINES+=-DTBT_ROOT=$(TBT_ROOT)
endif

.PHONY: all
all: SSDT-TbtOnPCH.aml

%.aml: %.sasl
	$(IASL) $<

%.sasl: %.pasl
	sed '/^#/ d' $< > $@

%.pasl: %.asl
	$(CC) -E -x c $(DEFINES) $< -o $@

.PHONY: clean
clean:
	rm -rf *.aml
