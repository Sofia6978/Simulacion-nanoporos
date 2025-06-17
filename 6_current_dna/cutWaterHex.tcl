# This script will remove water from psf and pdf outside of a
# hexagonal prism along the z-axis with a vertex along the x-axis.
# use with: vmd -dispdev text -e cutWaterHex.tcl
# jcomer2@uiuc.edu
package require psfgen 1.3

# Input:
set psf pore_solv.psf
set pdb pore_solv.pdb
# Output:
set psfFinal pore_hex.psf
set pdbFinal pore_hex.pdb

# Parameters:
# The radius of the water hexagon is reduced by "radiusMargin"
# from the pore hexagon. The distance is in angstroms.
set radiusMargin 1.0
# This is the stuff that is removed.
set waterText "water or ions"
# This selection forms the basis for the hexagon.
set selText "resname SIN"

# Load the molecule.
mol load psf $psf pdb $pdb

# Find the system dimensions.
set sel [atomselect top $selText]
set minmax [measure minmax $sel]
$sel delete
set size [vecsub [lindex $minmax 1] [lindex $minmax 0]]
foreach {size_x size_y size_z} $size {break}
# This is the hexagon's radius.
set rad [expr 0.5*$size_x]
set r [expr $rad - $radiusMargin]

# Find water outside of the hexagon.
set sqrt3 [expr sqrt(3.0)]
# Check the middle rectangle.
set check "($waterText) and ((abs(x) < 0.5*$r and abs(y) > 0.5*$sqrt3*$r) or"
# Check the lines forming the nonhorizontal sides.
set check [concat $check "(y > $sqrt3*(x+$r) or y < $sqrt3*(x-$r) or"]
set check [concat $check "y > $sqrt3*($r-x) or y < $sqrt3*(-x-$r)))"]
set w [atomselect top $check]
set violators [lsort -unique [$w get {segname resid}]]
$w delete

# Remove the offending water molecules.
puts "Deleting the offending water molecules..."
resetpsf
readpsf $psf
coordpdb $pdb
foreach waterMol $violators {
	delatom [lindex $waterMol 0] [lindex $waterMol 1]
}

writepsf $psfFinal
writepdb $pdbFinal
mol delete top
