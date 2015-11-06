proc intersectPortBounds { args } {
  # Process Input Arguments
  parse_proc_arguments -args $args results

  # Assign Variables for specified input arguments
  if { [info exists results(-bus1)] }    	{ set bus1 $results(-bus1) } 
  if { [info exists results(-bus2)] }    	{ set bus2 $results(-bus2) } 

  set even_dir "v"
  set odd_dir "h"
  set halfwidth 5
  set size [sizeof_collection [get_ports $bus1*]]

  for {set i 0} {$i < $size} {incr i} {

    if { $size == 1 } { 
      set port1 [get_ports $bus1]
      set port2 [get_ports $bus2]
    } else { 
      set port1 [get_ports $bus1[$i]]
      set port2 [get_ports $bus2[$i]]
    }

    set port1dir [get_attribute $port1 port_direction]
    set port2dir [get_attribute $port2 port_direction]

    if { $port1dir == "out"} { set port1_fan [all_fanin -flat -start -only -to $port1]
    } else { set port1_fan [all_fanout -flat -end -only -from $port1] }

    if { $port2dir == "out"} { set port2_fan [all_fanin -flat -start -only -to $port2]
    } else { set port2_fan [all_fanout -flat -end -only -from $port2] }

    set flop [remove_from_collection -intersect $port1_fan $port2_fan]

    if { [sizeof_collection $flop] == 0 } { continue }

    if { $port1dir == "out"} { 
      set port1_fan [all_fanin -flat -only -to $port1]
      set port1flop_fan [all_fanout -flat -only -from [get_pins -of $flop -filter full_name=~*/Q*]]
    } else { 
      set port1_fan [all_fanout -flat -only -from $port1] 
      set port1flop_fan [all_fanin -flat -only -to [get_pins -of $flop -filter full_name=~*/D*]]
    }
    set port1_logic [remove_from_collection -intersect $port1_fan $port1flop_fan]

    if { $port2dir == "out"} { 
      set port2_fan [all_fanin -flat -only -to $port2]
      set port2flop_fan [all_fanout -flat -only -from [get_pins -of $flop -filter full_name=~*/Q*]]
    } else { 
      set port2_fan [all_fanout -flat -only -from $port2] 
      set port2flop_fan [all_fanin -flat -only -to [get_pins -of $flop -filter full_name=~*/D*]]
    }
    set port2_logic [remove_from_collection -intersect $port2_fan $port2flop_fan]

    #Itersecting Logic
    set logic $port1_logic
    set logic [add_to_collection $logic $port2_logic]
    
    #X Y Intersection
    set layer1 [get_attribute $port1 layer]
    set layer2 [get_attribute $port2 layer]

    set layer1 [string range $layer1 1 end]
    set layer2 [string range $layer2 1 end]

    if { [expr $layer1 % 2] == 0 } { set dir1 $even_dir
    } else { set dir1 $odd_dir }
    
    if { [expr $layer2 % 2] == 0 } { set dir2 $even_dir
    } else { set dir2 $odd_dir }
    
    if { $dir1 != $dir2 } {
      if { $dir1 == "v" } {
        set ycenter [lindex [get_attribute $port2 center] 1]
        set xcenter [lindex [get_attribute $port1 center] 0]
      } else {
        set ycenter [lindex [get_attribute $port1 center] 1]
        set xcenter [lindex [get_attribute $port2 center] 0]
      }
    } else {
      if { $dir1 == "v" } { 
        set xport1 [lindex [get_attribute $port1 center] 0]
        set xport2 [lindex [get_attribute $port2 center] 0]
        set xcenter [expr ($xport1 + $xport2) / 2]
        set ycenter [lindex [get_attribute $port1 center] 1]
      } else {
        set xcenter [lindex [get_attribute $port1 center] 0]
        set yport1 [lindex [get_attribute $port1 center] 1]
        set yport2 [lindex [get_attribute $port2 center] 1]
        set ycenter [expr ($yport1 + $yport2) / 2]
      }
    }
    
    #Bounds
    set llx [expr $xcenter - $halfwidth]
    set urx [expr $xcenter + $halfwidth]
    set lly [expr $ycenter - $halfwidth]
    set ury [expr $ycenter + $halfwidth]
    create_bounds -type hard -coordinate "$llx $lly $urx $ury" -name ${bus1}__${bus2}_bound$i $logic

  } 
}
define_proc_attributes intersectPortBounds \
  -info "Takes a 2 buses and creates bounds for logic at their intersection." \
  -define_args {
    {-bus1       "Base name of port1 without brackets" "" string required}
    {-bus2       "Base name of port2 without brackets" "" string required}
  }

#test:
set bus1 "bus1"
set bus2 "bus2"
intersectPortBounds -bus1 $bus1 -bus2 $bus2

set bus1 "bus1"
set bus2 "bus2"
intersectPortBounds -bus1 $bus1 -bus2 $bus2

#DC? goodgood 
#ICC? goodgood


proc intersectionPointPort { args } {
  # Process Input Arguments
  parse_proc_arguments -args $args results

  # Assign Variables for specified input arguments
  if { [info exists results(-portname1)] }    	{ set portname1 $results(-portname1) } 
  if { [info exists results(-portname2)] }    	{ set portname2 $results(-portname2) } 

  set even_dir "v"
  set odd_dir "h"
  set port1 [get_ports $portname1]
  set port2 [get_ports $portname2]

  #X Y Intersection
  set layer1 [get_attribute $port1 layer]
  set layer2 [get_attribute $port2 layer]

  set layer1 [string range $layer1 1 end]
  set layer2 [string range $layer2 1 end]

  if { [expr $layer1 % 2] == 0 } { set dir1 $even_dir
  } else { set dir1 $odd_dir }
  
  if { [expr $layer2 % 2] == 0 } { set dir2 $even_dir
  } else { set dir2 $odd_dir }
  
  if { $dir1 != $dir2 } {
    if { $dir1 == "v" } {
      set ycenter [lindex [get_attribute $port2 center] 1]
      set xcenter [lindex [get_attribute $port1 center] 0]
    } else {
      set ycenter [lindex [get_attribute $port1 center] 1]
      set xcenter [lindex [get_attribute $port2 center] 0]
    }
  } else {
    if { $dir1 == "v" } { 
      set xport1 [lindex [get_attribute $port1 center] 0]
      set xport2 [lindex [get_attribute $port2 center] 0]
      set xcenter [expr ($xport1 + $xport2) / 2]
      set ycenter [lindex [get_attribute $port1 center] 1]
    } else {
      set xcenter [lindex [get_attribute $port1 center] 0]
      set yport1 [lindex [get_attribute $port1 center] 1]
      set yport2 [lindex [get_attribute $port2 center] 1]
      set ycenter [expr ($yport1 + $yport2) / 2]
    }
  }
  set coordlist [list $xcenter $ycenter]
  return $coordlist 
}
define_proc_attributes intersectionPointPort \
  -info "Takes a 2 ports and returns their intersection." \
  -define_args {
    {-portname1       "Name of port1" "" string required}
    {-portname2       "Name of port2" "" string required}
  }

set portname1 "bus1"
set portname2 "bus2"
set coord [intersectionPointPort -portname1 $portname1 -portname2 $portname2]

set i 0
set portname1 "bus1[$i]"
set portname2 "bus2[$i]"
set coord [intersectionPointPort -portname1 $portname1 -portname2 $portname2]
#DC? goodgood
#ICC? goodgood


proc snapToTrack { args } {
  # Process Input Arguments
  parse_proc_arguments -args $args results

  # Assign Variables for specified input arguments
  if { [info exists results(-position)] }    	{ set position $results(-position) } 
  if { [info exists results(-layer)] }    	{ set layer $results(-layer) } 

  #2w2s
  if {$layer eq "mmbop"} {
    set tracks 0
    set pwr_spc 0.000
    set pwr_wr 0.000
    set sig_spc 0.000
    set sig_wr 0.000
  }
  #outer edge to outer edge of signal wires
  set fullsigtrack [expr ($tracks*$sig_wr) + (($tracks-1)*$sig_spc)]
  set wr2wr_spc [expr $sig_wr + $sig_spc]
  
  set fullpwrtrack [expr ($pwr_spc * 2) + $pwr_wr]
  #middle of vss for all tracks starts on y=0 for horiz and x=0 for vert wires
  set fulltrack [expr $fullsigtrack + $fullpwrtrack]
  set edgewire_offset [expr ($pwr_wr / 2) + $pwr_spc + ($sig_wr / 2)]
  
  set track [expr int($position/$fulltrack)]
  set firstwire [expr ($track * $fulltrack) + $edgewire_offset]
  set lastwire [expr (($track + 1) * $fulltrack) - $edgewire_offset]
  if { $firstwire > $position } {
    set snap $firstwire
  } elseif { $lastwire < $position} {
    set snap $lastwire
  } else {
    set wirenum [expr int( ($position - $firstwire) / $wr2wr_spc )]
    set snap [expr $firstwire + ($wirenum * $wr2wr_spc)]
  }
  return $snap 
}
define_proc_attributes snapToTrack \
  -info "Takes an x or y position and a layer and returns nearest signal route for that layer." \
  -define_args {
    {-position       "x or y position" "" string required}
    {-layer       "route layer to snap to" "" string required}
  }

set position 2.2
set layer mmbop
snapToTrack -position $mypos -layer $mylayer




