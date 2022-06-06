#!/bin/bash --login
# this script is meant to be started in a directory in iridi5 with a li_int.dat file and a cubeproc.py program

#SBATCH --job-name chain_update
#SBATCH --partition amd
#SBATCH --ntasks=160
#SBATCH --nodes=10
#SBATCH --cpus-per-task=4
#SBATCH --ntasks-per-node=16
#SBATCH --time 60:00:00
#SBATCH --exclusive

# load relevent modules 
module purge
module load intel-compilers/19.0.3
module load intel-mkl/2019.3.199
module load intel-mpi/2018.3.222
module load intel-tools/2019.3
module load python/3.6.4
module load numpy 
export OMP_NUM_THREADS=4
export OMP_STACKSIZE=64M
export I_MPI_PMI_LIBRARY=/local/software/slurm/default/lib/libpmi.so

# find the directory where current calculations are occuring 
for x in {0..60}
do
    if [ -d $x ]
    then 
	max_dir_num=$x
    fi
done

# set the max number of lithiations to occur in this job
let li_num=$max_dir_num+3

# begin lithiation loop
for ((i=$max_dir_num; i<=li_num; i+=1)); do
    echo "Lithiation number: $i"
    let natoms=592+$i
    let natoms_pos=602+$i
    let j=$i-1
    declare -i pos_line="$(grep -n '%BLOCK POSITIONS_ABS' $i/592nano.dat | awk -F ':' '{print $1}')"

# if i is 0
    if (($i == 0)); then
	mkdir $i
        cp 592nano.dat $i
	srun /home/joh1e19/onetep_joh1e19/bin/onetep.iridis5.intel19.omp.scalapack $i/592nano.dat > $i/592nano.out
#	grep -A $natoms '%BLOCK POSITIONS_ABS' $i/592nano.out | tail $natoms | head -592 | sort -k4 -n > $i/positions.txt
	grep -A $natoms '%BLOCK POSITIONS_ABS' $i/592nano.out | tail $natoms > $i/positions.txt
	head -592 $i/positions.txt | sort -k4 -n > $i/nano_pos.txt
	sed -i '/^\s*$/d' $i/positions.txt
	sed -i '/^\s*$/d' $i/nano_pos.txt
	head -1 $i/nano_pos.txt | awk '{print $4}' > $i/upper_lower_i.txt
	tail -1 $i/nano_pos.txt | awk '{print $4}' >> $i/upper_lower_i.txt
	sed 's/#Li/Li/g' $i/592nano.dat > $i/tmp.dat
	mv $i/tmp.dat $i/592nano.dat

# if i is odd
    elif (( $i % 2)); then
# if i's directory exists
	if [ -d "$i" ]; then 
	    echo "The directory $i already exists"
# if i's directory contains a .geom file and the BFGS has not completed successfully
     	    if [ -f "$i/592nano.geom" ] && ! grep " BFGS : Geometry optimization completed successfully." $i/592nano.out > /dev/null ; then
		sed -i 's/#geom_continuation/geom_continuation/g' $i/592nano.dat
     		cat $i/592nano.out >> $i/592nano.out.old
		rm $i/592nano.out
		echo "Running GO calculation for lithiatin $i"
		srun /home/joh1e19/onetep_joh1e19/bin/onetep.iridis5.intel19.omp.scalapack $i/592nano.dat > $i/592nano.out
		sed -i 's/geom_continuation/#geom_continuation/g' $i/592nano.dat

# if the BFGS has already completed successfully
	    elif grep " BFGS : Geometry optimization completed successfully." $i/592nano.out > /dev/null ; then
		echo "bfgs already complete, moving on"
		if grep "BFGS : Final Configuration" $i/592nano.out > /dev/null ; then
		    grep -A $natoms_pos "BFGS : Final Configuration:" $i/592nano.out | tail -$natoms | awk '{print $2, $4, $5, $6}' > $i/positions.txt
		else
		    grep -A $natoms_pos "LBFGS: Final Configuration:" $i/592nano.out | tail -$natoms | awk '{print $2, $4, $5, $6}' > $i/positions.txt
		fi
		head -592 $i/positions.txt | sort -k4 -n > $i/nano_pos.txt
		sed -i '/^\s*$/d' $i/positions.txt
		sed -i '/^\s*$/d' $i/nano_pos.txt
		head -1 $i/nano_pos.txt | awk '{print $4}' > $i/upper_lower_i.txt
		tail -1 $i/nano_pos.txt | awk '{print $4}' >> $i/upper_lower_i.txt
	
		continue
# if there is no .geom file present and the directory exists
	    else
		echo "missing .geom file, breaking" 
		break
	    fi
# if i's directory does not exists
	else
	    mkdir $i
	    cp $j/592nano.dat $j/592nano_electrostatic_potential.cube $j/upper_lower_i.txt cubeproc.py $i
	    head -n -1 $i/592nano.dat > $i/tmp.dat
	    (cd $i; ./cubeproc.py >> tmp.dat)
	    echo '%ENDBLOCK POSITIONS_ABS' >> $i/tmp.dat
	    rm $i/592nano.dat
	    mv $i/upper_lower_i.txt $i/upper_lower_j.txt
	    sed 's/singlepoint/geometryoptimization/g' $i/tmp.dat > $i/592nano.dat
	    rm $i/592nano_electrostatic_potential.cube $i/cubeproc.py $i/tmp.dat
	    echo "Running GO calculation for lithiatin $i"
	    srun /home/joh1e19/onetep_joh1e19/bin/onetep.iridis5.intel19.omp.scalapack $i/592nano.dat > $i/592nano.out
	fi
	if grep "BFGS : Final Configuration" $i/592nano.out > /dev/null ; then
	    grep -A $natoms_pos "BFGS : Final Configuration:" $i/592nano.out | tail -$natoms | awk '{print $2, $4, $5, $6}' > $i/positions.txt
	else
	    grep -A $natoms_pos "LBFGS: Final Configuration:" $i/592nano.out | tail -$natoms | awk '{print $2, $4, $5, $6}' > $i/positions.txt
	fi
	head -592 $i/positions.txt | sort -k4 -n > $i/nano_pos.txt
	sed -i '/^\s*$/d' $i/positions.txt
	sed -i '/^\s*$/d' $i/nano_pos.txt
	head -1 $i/nano_pos.txt | awk '{print $4}' > $i/upper_lower_i.txt
	tail -1 $i/nano_pos.txt | awk '{print $4}' >> $i/upper_lower_i.txt
	

# if i is even
    else
	if [ -d $i ]; then
	    echo "$i directory exists, going to next lithiation."
	    break
	else
	    mkdir $i
	    cp $j/592nano.dat $j/592nano.out $j/592nano_electrostatic_potential.cube $j/upper_lower_i.txt cubeproc.py $i
	    if grep "BFGS : Final Configuration" $i/592nano.out; 
	    then
		grep -A $natoms_pos "BFGS : Final Configuration:" $i/592nano.out | tail -$natoms | awk '{print $2, $4, $5, $6}' > $i/cc.txt
	    else
		grep -A $natoms_pos "LBFGS: Final Configuration:" $i/592nano.out | tail -$natoms | awk '{print $2, $4, $5, $6}' > $i/cc.txt
	    fi
	fi
	head -79 $i/592nano.dat > $i/tmp_head_dat.txt
	cat $i/tmp_head_dat.txt $i/cc.txt >> $i/tmp.dat
	(cd $i; ./cubeproc.py >> tmp.dat)
	echo '%ENDBLOCK POSITIONS_ABS' >> $i/tmp.dat
	rm $i/592nano.dat
	mv $i/upper_lower_i.txt $i/upper_lower_j.txt
	sed 's/geometryoptimization/singlepoint/g' $i/tmp.dat > $i/592nano.dat
      	rm $i/cc.txt $i/tmp_head_dat.txt $i/592nano.out $i/592nano_electrostatic_potential.cube 
	$i/cubeproc.py $i/tmp.dat
	echo "Running SP calculation for lithiation $i"
	srun /home/joh1e19/onetep_joh1e19/bin/onetep.iridis5.intel19.omp.scalapack $i/592nano.dat > $i/592nano.out
	grep -A $natoms '%BLOCK POSITIONS_ABS' $i/592nano.out | tail -$natoms > $i/positions.txt
	head -592 $i/positions.txt | sort -k4 -n > $i/nano_pos.txt
	head -1 $i/nano_pos.txt | awk '{print $4}' > $i/upper_lower_i.txt
	tail -1 $i/nano_pos.txt | awk '{print $4}' >> $i/upper_lower_i.txt
   fi
done

