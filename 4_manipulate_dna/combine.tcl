# This script combines two pdb/psf pairs.
# Use with: vmd -dispdev text -e combine.tcl
# jcomer2@uiuc.edu

# Input:
set psf0 ../1_build/poro_mem.psf
set pdb0 ../1_build/poro_mem.pdb
set psf1 ssDna.psf
set pdb1 ssDna.pdb
# Output:
set finalPsf poro+dna.psf
set finalPdb poro+dna.pdb

# Load the topology and coordinates.
package require psfgen
resetpsf
readpsf $psf0
coordpdb $pdb0
readpsf $psf1
coordpdb $pdb1

# Write the combination.
writepdb $finalPdb
writepsf $finalPsf
