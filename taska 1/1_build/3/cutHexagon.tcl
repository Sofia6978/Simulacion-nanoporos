# Remove atoms from a pdb outside of a hexagonal prism
# along the z-axis with a vertex along the x-axis.
# Also write a file with NAMD cellBasisVectors. 
# Use with: vmd -dispdev text -e cutHexagon.tcl
# jcomer2@uiuc.edu

set fileNamePrefix bloque
# Input:
set pdbIn ${fileNamePrefix}.pdb
# Output:
set pdbOut ${fileNamePrefix}_hex.pdb
set boundaryFile ${fileNamePrefix}_hex.bound
set pdbTemp tmp1.pdb

# Write a pdb with the system centered.
proc centerPdb {pdbIn pdbOut} {
	mol load pdb $pdbIn
	set all [atomselect top all]
	set cen [measure center $all]
	$all moveby [vecinvert $cen]
	$all writepdb $pdbOut
	$all delete
	mol delete top
}

# Read the geometry of the system and write the boundary file.
# Return the radius of the hexagon.
proc readGeometry {pdbFile boundaryFile} {
	set remarkLines {}
	set inStream [open $pdbFile r]
	foreach line [split [read $inStream] \n] {
    	set string0 [string range $line 0 5]

    	if {![string match $string0 "REMARK"] } {break}
	lappend remarkLines $line
	
	set string1 [string range $line 7 end]
	if { [string match "a1 *" $string1] } {
	    foreach {tmp1 tmp2 a1} $line { break }
	    puts "a1 = $a1"
	}
	if { [string match "a2 *" $string1] } {
	    foreach {tmp1 tmp2 a2} $line { break }
	    puts "a2 = $a2"
	}
	if { [string match "a3 *" $string1] } {
	    foreach {tmp1 tmp2 a3} $line { break }
	    puts "a3 = $a3"
	}
	if { [string match "basisVector1 *" $string1] } {
	    foreach {tmp1 tmp2 x y z} $line { break }
	    set basisVector1 [list $x $y $z]
	    puts "basisVector1 = $basisVector1"
	}
	if { [string match "basisVector2 *" $string1] } {
	    foreach {tmp1 tmp2 x y z} $line { break }
	    set basisVector2 [list $x $y $z]
	    puts "basisVector2 = $basisVector2"
	}
	if { [string match "basisVector3 *" $string1] } {
	    foreach {tmp1 tmp2 x y z} $line { break }
	    set basisVector3 [list $x $y $z]
	    puts "basisVector3 = $basisVector3"
	}
	if { [string match "replicationCount *" $string1] } {
	    foreach {tmp1 tmp2 n1 n2 n3} $line { break }
	    puts "\{n1 n2 n3\} = \{$n1 $n2 $n3\}"
	}
    	}
	close $inStream

	# Deterimine the lattice vectors.
	set vector1 [vecscale $basisVector1 $a1]
	set vector2 [vecscale $basisVector2 $a2]
	set vector3 [vecscale $basisVector3 $a3]

	set pbcVector1 [vecscale $vector1 $n1]
	set pbcVector2 [vecscale $vector2 $n2]
	set pbcVector3 [vecscale $vector3 $n3]

	set hexVector1 [vecadd [vecscale $vector1 [expr $n1/2]] \
	[vecscale $vector2 [expr $n2/2]]]
	set hexVector2 [vecadd [vecscale $vector1 [expr -$n1/2] ] \
	[vecscale $vector2 [expr $n2]]] 

	puts ""
	puts "PERIODIC VECTORS FOR NAMD:"
	puts "cellBasisVector1                        $hexVector1"
	puts "cellBasisVector2                        $hexVector2"
	puts "cellBasisVector3                        $pbcVector3" 
	puts ""

	set radius [expr 2.*[lindex $hexVector1 0]/3.]
	puts "The radius of the hexagon: $radius"

	# Write the boundary condition file.
	set out [open $boundaryFile w]
	puts $out "radius           $radius"
	puts $out "cellBasisVector1 $hexVector1"
	puts $out "cellBasisVector2 $hexVector2"
	puts $out "cellBasisVector3 $pbcVector3" 
	close $out

	return $radius
}

proc cutHexagon {r pdbIn pdbOut} {
	set sqrt3 [expr sqrt(3.0)]
	
	# Open the pdb to extract the atom records.
	set out [open $pdbOut w]
	set in [open $pdbIn r]
	set atom 1
	foreach line [split [read $in] \n] {
    		set string0 [string range $line 0 3]
		
		# Just write any line that isn't an atom record.
		if {![string match $string0 "ATOM"]} {
			puts $out $line
			continue
		}
		
		# Extract the relevant pdb fields.
		set serial [string range $line 6 10]
		set x [string range $line 30 37]
		set y [string range $line 38 45]
		set z [string range $line 46 53]
		
		# Check the hexagon bounds.
		set inHor [expr abs($y) < 0.5*$sqrt3*$r]
		set inPos [expr $y < $sqrt3*($x+$r) && $y > $sqrt3*($x-$r)]
		set inNeg [expr $y < $sqrt3*($r-$x) && $y > $sqrt3*(-$x-$r)]
		
		# If atom is within the hexagon, write it to the output pdb
		if {$inHor && $inPos && $inNeg} {
			# Make the atom serial number accurate if necessary.
			if {[string is integer [string trim $serial]]} {
				puts -nonewline $out "ATOM  "
				puts -nonewline $out \
				[string range [format "     %5i " $atom] end-5 end]
				puts $out [string range $line 12 end]
				
			} else {
				puts $out $line
			}
			
			incr atom
		}
	}
	close $in
	close $out
}

set radius [readGeometry $pdbIn $boundaryFile]
centerPdb $pdbIn $pdbTemp 
cutHexagon $radius $pdbTemp $pdbOut

