VIVADO  ?= vivado
BITFILE  = build/FpgaTop.bit

SOURCES  = $(wildcard ../../rtl/*.sv)
SOURCES += $(wildcard ../../RingBuffer/rtl/*.sv)
SOURCES += ../../sim/HermesNoC.sv
SOURCES += $(wildcard *.sv)
SOURCES += nexys_a7.xdc

.PHONY: all bit synth impl prog clean

all: bit

synth: build/post_synth.dcp

impl: build/post_route.dcp

bit: $(BITFILE)

build/post_synth.dcp: $(SOURCES)
	mkdir -p build
	$(VIVADO) -mode batch -source synth.tcl \
	          -log build/synth.log -journal build/synth.jou

build/post_route.dcp: build/post_synth.dcp $(SOURCES)
	$(VIVADO) -mode batch -source impl.tcl \
	          -log build/impl.log -journal build/impl.jou

$(BITFILE): build/post_synth.dcp build/post_route.dcp $(SOURCES)
	$(VIVADO) -mode batch -source build.tcl \
	          -log build/build.log -journal build/build.jou

prog: $(BITFILE)
	$(VIVADO) -mode batch -source prog.tcl \
	          -log build/prog.log -journal build/prog.jou

clean:
	rm -rf build .Xil vivado*.jou vivado*.log
