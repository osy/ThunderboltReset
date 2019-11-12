IASL=iasl
TARGET?=NUC_Hades_Canyon

.PHONY: all
all: SSDT-TbtOnPCH.aml

%.aml: %.sasl
	$(IASL) $<

%.sasl: %.pasl
	sed '/^#/ d' $< > $@

%.pasl: %.asl
	$(CC) -E -x c -DTARGET=$(TARGET) $< -o $@

.PHONY: clean
clean:
	rm -rf *.aml
