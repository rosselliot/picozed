Repository to hold source files for building FPGA projects using the PicoZed / FPGAIOC carrier board.

To clone:
`git clone --recurse-submodules git@gitlab.esss.lu.se:icshwi/picozed.git`

To build:

```
make board=<board_name> project=<project_name> <stage>

where, 
    <board_name>   := picozed
    <project_name> := {base, fmc-dio-5ch-ttl, ethercat-slave}
    <stage>        := project     - Create the Vivado GUI project 
                      synth       - Run Synthesis on the design  
                      impl        - Run Implementation on the design  
                      bitstream   - Generate the bitstream
                      all         - All of the above
                    
```

*NOTE:* ethercat-slave project requires a node-locked IP license from Beckhoff.

Default target is 'all', so to make a bitstream for the PicoZed board, just run:

`make board=picozed project=base`

Generated bitstream file will be in *output/<project_name>/<board_name>_<project_name>.bit*
