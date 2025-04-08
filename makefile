PATH:= $(PATH):/opt/riscv32i/bin/
CC := riscv32-unknown-elf-gcc
NM:= riscv32-unknown-elf-nm
OBJCOPY:= riscv32-unknown-elf-objcopy 
OBJDUMP:= riscv32-unknown-elf-objdump

all : test.asm  test.map  test.mem32  tb_sys_picorv32.vcd test.mif 

test.hex: 	jumpstart.s test.c	
	$(CC) -o $@  $^     -T linker.lds -nostartfiles
test.map : test.hex
	$(NM) $^  > $@
test.mem : test.hex
	$(OBJCOPY)  -O verilog  $^ $@
test.mem32 : test.mem VlogMem8to32
	./VlogMem8to32 <test.mem > test.mem32
test.mif : test.mem VlogMem_to_QuartusMIF
	./VlogMem_to_QuartusMIF  <test.mem > test.mif
VlogMem8to32 : VlogMem8to32.c
	cc -o $@ $^
VlogMem_to_QuartusMIF : VlogMem_to_QuartusMIF.c
	cc -o $@ $^
test.sec : test.hex
	$(OBJDUMP) $^  > $@
test.asm : test.hex
	$(OBJDUMP) $^  -d > $@
tb_sys_picorv32.vvp  :  picorv32.v  system_picorv32.v  tb_sys_picorv32.v test.mem32 ram1port8k_sim.v BCDto7seg.v 
	iverilog  -o $@  picorv32.v  system_picorv32.v  tb_sys_picorv32.v  ram1port8k_sim.v BCDto7seg.v 
tb_sys_picorv32.vcd :tb_sys_picorv32.vvp
	vvp   $^ > trace.txt
clean : 
	/bin/rm -f test.hex  *.mem *.map *.elf *.hex  tb_picorv32  *.vcd *.asm VlogMem8to32 VlogMem_to_QuartusMIF *.vvp  trace.txt vsim.wlf test.mif test.mem32 ; rm -rf db incremental_db output_files simulation *.qws 
