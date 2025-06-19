# to use: vmd -dispdev text -e addWater.tcl

package require solvate
solvate poro+dna.psf poro+dna.pdb +z 20 -z 20 -o pore_solv
file delete combine.psf combine.pdb
mol delete top

