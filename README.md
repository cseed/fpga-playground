Playground for FPGA-related projects.

arty/eth-led
============

eth-led is a project for Digilent's [Arty](http://store.digilentinc.com/arty-artix-7-fpga-development-board-for-makers-and-hobbyists/) board.

eth-led writes the payload of an Ethernet packet sent to it to the
LEDs.  It writes the low nibble of the first byte of the payload.  Its
Ethernet address is 12:34:56:78:9a:bc.  You can use
[lltx](https://github.com/cseed/net-playground) to send an Ethernet
packet.

On Linux with Vivado installed, just run `make` to build the bitstream
and `make program` to flash the board.  Tested with Vivado 2016.4.

rom
===

Example of initializing a ROM with the .text section of a RISC-V
executable in Verilog.

timing
======

Timing experiments.

design | xc7a35t-1li (Arty) | ku035-2e
------ | ---------------- | --------
1-bit toggle flip-flop | 1.237ns / 808.4MHz | 0.293ns / 3.413GHz
32-bit adder | 2.723ns / 367.2MHz | 1.257ns / 795.5MHz
32Kb RAM* | 3.567ns / 280.3MHz | 2.124ns / 470.8MHz

*This is a lower bound.  I was interested in seeing the timing for
BRAMs.  When I increase the clock constraint, Vivado converts the
memory into distributed RAM.  In neither case was the BRAM on the
critical path.  Maximum BRAM timing from datasheet is: xc7a35t-1li:
388.2MHz, ku035-2e: 585MHz.  TODO: try explicitly instantiating the
BRAM to see if that stops Vivado from converting it to distributed
RAM.
