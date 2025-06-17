# to use: vmd -dispdev text -e addWater.tcl

package require solvate
solvate pore.psf pore.pdb +z 20 -z 20 -o pore_solv
file delete combine.psf combine.pdb
mol delete top

