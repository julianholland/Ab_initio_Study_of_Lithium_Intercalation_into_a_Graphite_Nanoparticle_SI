This is the supporting information data for the paper
"Ab-initio Study of Lithium Intercalation into a Graphite Nanoparticle"

The directories are split as follows

1. Graphite_Benchmark

   Contains the ONETEP .out files for all functionals tested in section 3.2 of the paper. The directory name indicates the functional used and the name of the file indicates the interlayer spacing. In every directory there is a "10A_seperation_for_be" directory which was used in order to calculate the binding energy by computing the energy of an "infinite" interlayer spacing.

2. PBE-D2_no_restrictions

   Contains the ONETEP .out files for all lithiations relevent to what was discussed in section 3.5 in the paper. Also contains relevent scripts required for launching the calcualtions on the Iridis5 supercomputer.

3. PBE-D2

   Contains the ONETEP .out files for all lithiations relevent to what was discussed in section 4.1 in the paper. Also contains relevent scripts required for launching the calcualtions on the Iridis5 supercomputer.

4. optPBE

   Contains the ONETEP .out files for all lithiations relevent to what was discussed in section 4.1 in the paper. Also contains relevent scripts required for launching the calcualtions on the Iridis5 supercomputer.

For 2, 3, and 4:

The geometry optimisation .out files are the ones that are created when the calculation converges. i.e. they may not display the entire geometry relaxation. In order to rerun these you can go to the previous lithiation (typically a single point) and rerun that calculation, then use the relevent cubeproc.py script, in the scripts directory, to find the electrostatic potential minimum and add the output to the bottom of the previous .dat file. This will generate the initial starting structure we used or you can trust the initial partially relaxed structure we provide and continue with the coordinates given in the .out file.



5. AB Pinning

   Contains the ONETEP .out files for all structures tested in section 4.5 of the paper. the first two letter of the file name indicate the graphite stacking. "empty" implies no lithiation, "full" implies 42 Li's intercalted, and "estat" or "perfect" indicates the filling method (either through our electrostatic minimum technique "estat" or perfectly spaced "perfect"). AA stacking is always perfectly spaced. 
