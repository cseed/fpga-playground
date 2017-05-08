Playground for FPGA-related projects.

eth-led
=======

eth-led is a project for Digilent's [Arty](http://store.digilentinc.com/arty-artix-7-fpga-development-board-for-makers-and-hobbyists/) board.

eth-led writes the payload of an Ethernet packet sent to it to the
LEDs.  It writes the low nibble of teh first byte of the payload.  Its
Ethernet address is 12:34:56:78:9a:bc.  You can use
[lltx](https://github.com/cseed/net-playground) to send an Ethernet
packet.

On Linux with Vivado installed, just run `make` to build the bitstream
and `make program` to flash the board.  Tested with Vivado 2016.4.
