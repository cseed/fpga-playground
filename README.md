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
1-bit toggle flip-flop | 1.181ns / 846.7MHz | 0.294ns / 3.401GHz
32-bit adder | 2.744ns / 364.3MHz | 1.257ns / 795.5MHz
32Kb RAM* | 3.49ns / 286.5MHz | 1.707ns / 585.8MHz

*Vivado may implement either as a Block RAM or distributed RAM.

To find the timing, do binary search on the clock constraint starting
from 3ns to the nearest 0.1ns.  When the constraint is met, take the
constraint minus the reported slack as the new upper bound.
