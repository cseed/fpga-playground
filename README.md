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

arty/ddr3
=========

A minimal DDR3 example using the AXI interface for the Arty.  IP
creation (clk_wiz and MIG) is scripted.  `mig.prj` is slightly
modified from the Arty [board
files](https://github.com/Digilent/vivado-boards/tree/master/new/board_files).
A simple state machine performs a write and readback.  The LEDs mean:

* LD0: the write finished
* LD1: the read finished
* LD2: the value read back matches the value written

To build:

```
$ make create_ip
$ make synth
```

Run `make program` to flash the board.

rom
===

Example of initializing a ROM with to 0-he .text section of a RISC-V
executable in Verilog.

timing
======

Timing experiments.

design | xc7a35t-1li (Arty) | ku035-2e
------ | ---------------- | --------
1-bit toggle flip-flop | 1.181ns / 846.7MHz | 0.294ns / 3.401GHz
32-bit adder | 2.744ns / 364.3MHz | 1.257ns / 795.5MHz
32-bit shifter | 2.837ns / 352.5MHz | 1.302ns / 768MHz
32Kb RAM* | 3.49ns / 286.5MHz | 1.707ns / 585.8MHz

*Vivado may implement either as a Block RAM or distributed RAM.

To find the best timing, I do binary search on the clock constraint
starting from 3ns to the nearest 0.1ns.  When the constraint is met,
take the constraint minus the reported slack as the new upper bound.
This idea was gratuitously stolen from Clifford Wolf's
[picorv32](https://github.com/cliffordwolf/picorv32) Vivado scripts.
