Repository to hold source files for building FPGA projects using the FMC Digital-IO 5 channel TTL board.

To clone:
`git clone --recurse-submodules git@gitlab.esss.lu.se:icshwi/fmc-dio-5ch-ttl.git`

To build:

```
make project=<board_name> <stage>

where, 
    <board_name> := picozed
    <stage>      := project     - Create the Vivado GUI project 
                    synth       - Run Synthesis on the design  
                    impl        - Run Implementation on the design  
                    bitstream   - Generate the bitstream
                    all         - All of the above
                    
```

Default target is 'all', so to make a bitstream for the PicoZed board, just run:

`make project=picozed`



