This is the supporting information data for the paper
"Ab-initio Study of Lithium Intercalation into a Graphite Nanoparticle"

The directories are split as follows

1. PBE-D2_no_restrictions

   containst the ONTEP .out files for all lithiations relevent to what was discussed in section 3.5 in the paper. Also contains relevent scripts required for launching the calcualtions on the Iridis5 supercomputer.

2. PBE-D2

   containst the ONTEP .out files for all lithiations relevent to what was discussed in section 4.1 in the paper. Also contains relevent scripts required for launching the calcualtions on the Iridis5 supercomputer.

3. optPBE

   containst the ONTEP .out files for all lithiations relevent to what was discussed in section 4.1 in the paper. Also contains relevent scripts required for launching the calcualtions on the Iridis5 supercomputer.


The geometry optimisation .out files are the ones that are created when the calculation converges. i.e. they may not display the entire geometry relaxation. In order to rerun these you can go to the previous lithiation (typically a single point) and rerun that calculation, then use the relevent cubeproc.py script, in the scripts directory, to find the electrostatic potential minimum and add the output to the bottom of the previous .dat file. This will generate the initial starting structure in our script.
