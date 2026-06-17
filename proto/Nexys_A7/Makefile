VIVADO  ?= vivado
BITFILE  = build/FpgaTop.bit

.PHONY: all bit prog clean

all: bit

bit:
	mkdir -p build
	$(VIVADO) -mode batch -source build.tcl \
	          -log build/build.log -journal build/build.jou

prog: $(BITFILE)
	$(VIVADO) -mode batch -source prog.tcl \
	          -log build/prog.log -journal build/prog.jou

clean:
	rm -rf build .Xil vivado*.jou vivado*.log
