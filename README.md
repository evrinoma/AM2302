# Description
This is a hardware project designed to drive AM2302 temperature/Humidity sensor. The project has been tested and successfully run on the Altera CPLD series MAX II.  FSM core, written in Verilog.

Most of these hardware modules are well tested and shouldn't have issues. 
The project consist from three parts 
- hardware description
- tests
- upload to cpld

All you need to create AM2302 is low cost development board with CPL like a Altera Max series or other similar. Next you should open the project file .qpf with a different version of Quartus software, in my case 15.0. Compile and test the project. After upload code to development board,  you can get byte sequence from sensor, and now convert it to real data. Finally, if you have a raspberyPi board and you would like to compare data gather from hardware. You should build AM2302 1-ware reader just run 
- make all

And you've got a test program for the AM2302/DHT22 temperature and humidity sensor.

## Licence
This is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. See <http://www.gnu.org/licenses/>.

## Thanks

## Done
Lots of information about this project can be found here
https://sites.google.com/site/evrinoma/cpld/cpld-and-am2302
https://sites.google.com/site/evrinoma/cpld/cpld-and-am2302-2
