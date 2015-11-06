proc groupBus { args } {
  # Process Input Arguments
  parse_proc_arguments -args $args results

  # Assign Variables for specified input arguments
  if { [info exists results(-bus)] }    	{ set bus $results(-bus) } 
  if { [info exists results(-layer)] }  	{ set layer $results(-layer) }
  if { [info exists results(-endbits)] }   	{ set endbits $results(-endbits) }
  if { [info exists results(-ylocs)] }   	{ set ylocs $results(-ylocs) }
  
  set x [lindex [get_location $bus[0]] 0]

  # Set layer spacings(um)
  if {$layer eq "1"} {
    set tracks 1
    set pwr_spc 0.11
    set pwr_wr 0.11
    set sig_spc 0.11
    set sig_wr 0.11
    set layerx 0.11
    set layery 0.11
  } elseif {$layer eq "1"} {
    set tracks 1
    set pwr_spc 0.11
    set pwr_wr 0.11
    set sig_spc 0.11
    set sig_wr 0.11
    set layerx 0.11
    set layery 0.11
  } elseif {$layer eq "1"} {
    set tracks 1 
    set pwr_spc 0.11
    set pwr_wr 0.11
    set sig_spc 0.11
    set sig_wr 0.11
    set layerx 0.11
    set layery 0.11
  } elseif {$layer eq "1"} {
    set tracks 1
    set pwr_spc 0.11
    set pwr_wr 0.11
    set sig_spc 0.11
    set sig_wr 0.11
    set layerx 1
    set layery 0.11
  }
  
  set fulltrack [expr ($tracks*$sig_wr) + (($tracks-1)*$sig_spc)]
  set nextfulltrack [expr (2*$pwr_spc) + $pwr_wr]
  #middle of vss for all tracks starts on y=0
  set start_track_offset [expr int(1000*($fulltrack + $pwr_spc + ($pwr_wr / 2)))]
  
  set range [llength $endbits]
  for {set j 0} {$j < $range} {incr j} { 
    #get y-span for the group
    set numbits [expr [lindex $endbits $j] + 1]
    set numfulltracks [expr int($numbits / $tracks)]
    set remainder [expr $numbits % $tracks]
    set span [expr ($numfulltracks * $fulltrack) + ($numfulltracks * $nextfulltrack) + (($remainder*$sig_wr) + (($remainder-1)*$sig_spc))]
    set rough_y [expr [lindex $ylocs $j] + double($span / 2)]
    set offset  [expr (int(1000*$rough_y) - $start_track_offset) % int(1000*($fulltrack + $nextfulltrack))]
    set exact_y [expr $rough_y - double($offset)/1000 - $sig_wr] 

    #place ports in the group
    if {$j == 0} { set start 0 } else { set start [expr [lindex $endbits [expr $j - 1]] + 1] }
    set stop [expr [lindex $endbits $j] + 1]

    for {set i $start} {$i < $stop} {incr i} {
      set tracknumber [expr $i % $tracks]
      set trackoffset [expr int($i/$tracks) * ($fulltrack + $nextfulltrack)]
      set y [expr $exact_y - ($tracknumber * ($sig_spc + $sig_wr)) - $trackoffset] 
      set_port_location -coor "$x $y" [get_port $bus[$i]] -layer_name $layer -layer_area "0 0 $layerx $layery"
    }
  }
  set_attr [get_ports $bus] is_fixed true
}

define_proc_attributes groupBus \
  -info "takes a bus and breaks/places it into groups defined by user" \
  -define_args {
    {-bus       "Name of the bus to be placed" "" string required}
    {-layer     "Layer of the bus to be placed" "" string required}
    {-endbits   "List of end bits of each group in bus" "" string required}
    {-ylocs     "List of ave y locations of each group in bus" "" string required}
  }

groupBus -bus III_WhoRdOut_ 	-layer 1 -endbits [list 63 145 227 291] 	-ylocs [list 1680 1460 540 330]
groupBus -bus FFF_WhoWrWho_ 	-layer 1 -endbits [list 63 145 227 291] 	-ylocs [list 1740 1510 510 300]
groupBus -bus FFF_WhenWho_3 		-layer 1 -endbits [list 63 127 191 255] 	-ylocs [list 1753 1500 573 290]
groupBus -bus FFF_RemWhenWho 		-layer 1 -endbits [list 63 127 195 255] 	-ylocs [list 1767 1610 417 217]
#groupBus -bus FFF_WhereWhenWho 	-layer 1 -endbits [list 63 127 195 255] 	-ylocs [list 1780 1620 430 220]
groupBus -bus FFF_WhenWho 		-layer 1 -endbits [list 63 127 191 255] 	-ylocs [list 1827 1550 467 230]
#groupBus -bus FFF_WhatWhenWho 		-layer 1 -endbits [list 63 127 191 255] 	-ylocs [list ]
#groupBus -bus III_WhatWhenWho 	-layer 1 -endbits [list 63 127 191 255] 	-ylocs [list ]
groupBus -bus FFF_WhenWhoWhere 		-layer 1 -endbits [list 63 127 191 255] 	-ylocs [list 1780 1620 430 197]
groupBus -bus III_WhenWhenWho 	-layer 1 -endbits [list 63 127 191 255] 	-ylocs [list 1780 1620 430 197]
groupBus -bus FFF_WhenWho_4 		-layer 1 -endbits [list 63 127 191 255] 	-ylocs [list 1700 1467 540 310]
groupBus -bus FFF_HowWho_4 		-layer 1 -endbits [list 63 127 191 255] 	-ylocs [list 1740 1480 560 277]
groupBus -bus FFF_WhenWho 		-layer 1 -endbits [list 63 127 191 255] 	-ylocs [list 1840 1570 480 210]
groupBus -bus FFF_WhoWrRepairCol	-layer 6 -endbits [list 1 3] 			-ylocs [list 1510 400]
groupBus -bus FFF_HowWhoEcc_4 	-layer 1 -endbits [list 16 33] 		-ylocs [list 1520 630]
