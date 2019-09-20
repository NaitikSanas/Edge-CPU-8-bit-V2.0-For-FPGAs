# Edge-CPU-8-bit-V2.0-For-FPGAs
CPU edge is light weight general purpose Soft core processor for FPGAs with powerful 49 instructions can be clocked up to 70 MHz*. 
# Features:
2 bidirectional IO ports 
Extensible peripherals upto 256 by using the internal CPU bus.
256x8 RAM.
128x128x8 grahpics buffer.
single UART communication interface

# Technical details of memories
Edge CPU consists separate Program and data memory. for writing programs in program ROM take care of following :

on start up Program counter is initialised with value of 0x00 and it starts executing the instruction written in program memory at 0x00. Unused sectors of memory is set to value NOP which is 0x00 since the VHDL do not accept the code.for example the your CPU program size is 29 bytes then unused sector 31, 32 should contain any value that CPU do nothing with it.

if last instruction specifies to go to begining of program or to any specified other location of memory and loop the program again, the values written in unused sector doesn't matter to always be NOP. since it will never let cpu go under unused sector. but still it is good practice to leave unused sectors with NOP value which is a instruction of CPU to do No OPeration.

The RAM can Read and Write data coming/going from/to ALU. and ALU can Get data from ALL possible sources in CPU like UART, IO ports, Program ROM and RAM itself.The RAM of CPU have no direct access to all the peripheral devices.

RAM only supports Direct addressing and Stack type Operation(with Push, POP instruction) for now.

# Instruction Fetch Decode Execution 
The instruction from ROM is fetched on Rising edge of clock and Decoded on the Falling Edge. program counter also increments on Falling Edge which helps to Prefetch the instruction as soon as the current instruction about to complete last operation. However the behaviour of PC depends upon type of instruction being Executed the various control words is created accross the IDCU(Instruction decoding and controlling Unit) with respect to the neccesary Timings. 
 
for example if Move_prg_mem_acc,"Value_X" instruction is fetched to move data Value_X from program memory to accumulator the IDCU Holds the Current Instruction then XALU register is set to Write_acc which writes Accumulator at upcoming rising edge and Increments Program counter to next address at same time. then ALU copies Content Available across Program memory on rising edge then PC incremented at falling edge and next instruction to be execute is fetched on rising edge which will be executed on falling edge.it means only 2 clocks to fetch data from program memory.

this is how IDCU extracts Control Sets for different blocks of CPU from instruction fetched which is extremly timing optimized such that it can do more on each clock cycle.

ICDU has the internal Address and Data Bus of 8Bit width with enable and write read capable to interface extra peripheral IO device which can address devices. and Data bus used to  write Data, internal address, control word of that device.
