#!/usr/bin/env python3.6

# code developed for second attempt at lithium intercalation. It finds the minimum isovalue of the electrostatic potential .cube file from ONETEP within the the structure (by limiting the range of the search)
import numpy as np
import os
import sys

class CubeFile:
    import numpy as np
    def __init__(self, filename):
        self.filename = filename
    
    def read_header(self):
        """Read the header or metadata part of the .cube file.

        Check the units of the file make sense, and read the following
        attributes.

        Attributes added:
        comment: The 2 comment lines.
        natoms: The number of atoms.
        origin: 1D vector defining the origin of the box.
        basis_vecs: 3x3 matrix with the 3 basis vectors as rows.
        nvox: 1D vector of the number of voxels in each direction.
        angstrom: Specifies units, True if Angstrom, False if Bohr.
        all_atoms: List of all atoms in the system, name and coordinate.
        file_position: Position in file where header ends/voxels begin.
        """
        with open(self.filename) as f:
            # comment lines
            comment = []
            comment.append(f.readline().strip())
            comment.append(f.readline().strip())
            self.comment = comment

            # number of atoms and the origin 
            natoms, x_0, y_0, z_0 = f.readline().strip().split()
            natoms = int(natoms)
            self.natoms = natoms
            self.origin = np.array([float(x_0), float(y_0), float(z_0)])

            # number of voxels and basis vectors a, b and c
            a_nvox, a_x, a_y, a_z = f.readline().strip().split()
            b_nvox, b_x, b_y, b_z = f.readline().strip().split()
            c_nvox, c_x, c_y, c_z = f.readline().strip().split()
            self.basis_vecs = np.array([[float(a_x), float(a_y), float(a_z)],
                                        [float(b_x), float(b_y), float(b_z)],
                                        [float(c_x), float(c_y), float(c_z)]])

            nvox = np.array([int(a_nvox), int(b_nvox), int(c_nvox)])
            # checks for bohr (+ve) or ang (-ve)
            if np.all(nvox > 0):
                self.angstrom = False
            elif np.all(nvox < 0):
                self.angstrom = True
                nvox *= -1
            else:
                # if units are mixed, which the .cube specification appears to
                # allow, a warning is given, as any geometric calculations will
                # not be correct
                print('warning: mixed bohr and angstrom units in {},\n'.format(
                      self.filename) + 'angstrom attribute has not been set')
                nvox = np.abs(nvox)

            self.nvox = nvox

            # atomic position data
            all_atoms = []
            for _ in range(natoms):
                all_atoms.append(f.readline().strip().split())

            self.all_atoms = [[atom[0], np.array([float(atom[2]),
                float(atom[3]), float(atom[4])])] for atom in all_atoms]

            # position in the file where header ends and voxels begin
            self.file_position = f.tell()

    def read_voxels(self):
        """Read the voxel part of a .cube file.
        
        The read_header method must be called before this one.
        Store voxels as 3D numpy array, preserving the shape of the
        .cube data.
        
        Attributes added:
        vox_array: 3D array of all voxels in the cube file.
        """
        with open(self.filename) as f:
            f.seek(self.file_position)
            tot_vox = np.prod(self.nvox)
            vox_array = np.empty(tot_vox)
            idx = 0
            for line in f:
                for voxel in line.strip().split():
                    vox_array[idx] = voxel
                    idx += 1
                    
        self.vox_array = np.reshape(vox_array, self.nvox)

# assigns variables to highest and lowest z-coords
f = open("upper_lower_i.txt", "r")
lower = float(f.readline())
upper = float(next(f))
f.close()

# executes cubefile code written by Tom
a = CubeFile('592nano_electrostatic_potential.cube')
a.read_header()
a.read_voxels()


# sets variables to restrict atom placement to within the structure (no adsorption)
vox_up = int(upper/float(a.basis_vecs[2,2]))-10
vox_lo = int(lower/float(a.basis_vecs[2,2]))+10
vox_dif= vox_up-vox_lo
vox_lo_dif= int(a.nvox[0])-vox_lo
# uncomment below line to print variable values
#print('vox_up', vox_up, '\n vox_lo',  vox_lo, '\n vox_dif',  vox_dif, '\n vox_lo_dif',  vox_lo_dif, '\n a.nvox[1]', a.nvox[1])

# Uncomment below to restrict atom placement

# restricts atom placement
#l = slice(0, vox_lo)
#high_vox_array = np.delete(a.vox_array, l, axis=2)
#u = slice  (vox_dif, vox_lo_dif)
#lim_vox_array = np.delete(high_vox_array, u, axis=2)

# find s minimum location
m = np.amin(lim_vox_array)
x_mv = np.where(lim_vox_array == m)[0][0]
y_mv = np.where(lim_vox_array == m)[1][0]
z_mv = np.where(lim_vox_array == m)[2][0]
z_mvl= z_mv + vox_lo
t_mv = np.array([x_mv,y_mv,z_mvl])

# Translates voxels to bohr cartesian coordinates and outputs in a good format
b_vec_diag = np.array([a.basis_vecs[0,0],a.basis_vecs[1,1],a.basis_vecs[2,2]])
li_coord = np.multiply(t_mv, b_vec_diag)
ang = [0.529177, 0.529177, 0.529177]
li_coord_ang =np.multiply(li_coord, ang)
print('Li {:9.6f} {:9.6f} {:9.6f}'.format(li_coord[0], li_coord[1], li_coord[2]))
# unhash to get result in angstrom
#print('Li {:9.6f} {:9.6f} {:9.6f}'.format(li_coord_ang[0], li_coord_ang[1], li_coord_ang[2]))


