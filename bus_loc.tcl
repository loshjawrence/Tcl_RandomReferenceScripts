
#create tcl file for selected ports to create bus strings:
#set myports [filter_collection [get_selection] object_class==port]
#foreach_in_collection port $myports {
#  echo [get_object_name $port]
#} > ../../../portsofinterest
#cat portsofinterest | sed 's/[0-9]*\]$//g' | sort -u | awk '{print "\""$1"*\""}' | sed 's/\[\*/\[\*\]/g' | grep -v FEED
#grep -A1 Ports bus_location_info | grep -v 'All\|no\|--' >> portfan_y
proc get_port_location_stats { args } {
  parse_proc_arguments -args $args results
  if { [info exists results(-dimension)] }		{ set dim $results(-dimension) } 
  if { [info exists results(-ports)] }			{ set ports $results(-ports) }
  if { [info exists results(-busname)] }		{ set busname $results(-busname) }
  set worstslack 20000
  set sum 0
  set total [sizeof_collection $ports]
  set min 20000
  set max -1
  foreach_in_collection port $ports {
    set loc [lindex [get_location $port] $dim]
    set sum [expr $sum + $loc]
    if {$loc > $max} {
      set max $loc
    }
    if {$loc < $min} {
      set min $loc
    }  
    set layer [get_attribute $port layer]
  }
  set ave [expr $sum/$total]
  set range [expr $max-$min]
  set return_string "$busname port location stats:\nave: $ave\nmin: $min\nmax: $max\nlayer: $layer\n"
  return $return_string
}
define_proc_attributes get_port_location_stats \
  -info "iteratates on a bus and calculates some stats on the bus" \
  -define_args {
      {-dimension      "0 is x dimension 1 is y dimension" "" int required}
      {-ports     "handle for port collection" "" string required}
      {-busname     "bus name" "" string required}
  }

proc get_long_distance_ports { args } {
  parse_proc_arguments -args $args results
  if { [info exists results(-dimension)] }		{ set dim $results(-dimension) } 
  if { [info exists results(-ports)] }			{ set ports $results(-ports) }
  if { [info exists results(-busname)] }		{ set busname $results(-busname) }
  set pos_range 100
  set neg_range -100
  set diffave 0
  set diffsum 0
  set hit 0
  set totalports [sizeof_collection $ports]
  set return_string ""
  append return_string "Ports with average fanout/fanin locations greater than 100um away from port on bus $busname:\n"
  foreach_in_collection port $ports {
    set dir [get_attribute $port port_direction]
    if { $dir eq "in"} {
      set points [all_fanout -flat -end -from $port]
    } else {
      set points [all_fanin -flat -start -to $port]
    }
    set total [sizeof_collection $points]
    set sum 0
    
    foreach_in_collection point $points {
      set sum [expr $sum + [lindex [get_location $point] $dim]]
    }
    if {$total != 0} {
      set ave [expr $sum/$total]
      set diff [expr $ave - [lindex [get_location $port] $dim]]
      set diffsum [expr $diffsum + $diff]
      if {$diff > $pos_range || $diff < $neg_range} {  
        set hit 1
        append return_string "$diff um : [get_object_name $port]\n"
      } 
    } else {
      append return_string "no start/endpoints on [get_object_name $port]\n"
    }
  }
  if {$hit == 0} {
    append return_string "All start/endpoints within $pos_range um of ports\n"
  } 
  set diffave [expr $diffsum/$totalports]
  append return_string "Ave fanout distance for $busname: $diffave um\n"
  return $return_string
}
define_proc_attributes get_long_distance_ports \
  -info "iteratates on a bus and calculates some stats on the bus" \
  -define_args {
      {-dimension      "0 is x dimension 1 is y dimension" "" int required}
      {-ports     "handle for port collection" "" string required}
      {-busname     "bus name" "" string required}

  }


source ../../../bus_strings.tcl
#SET THESE PARAMETERS:
set info_string ""
#what axis are the ports on? 0=x, 1=y
set dimension 1

foreach busname $bus_strings {
  set busports [get_ports $busname]
  append info_string "\n\nSize of $busname: [sizeof_collection $busports]\n"
  append info_string [get_port_location_stats -dimension $dimension -ports $busports -busname $busname]
  append info_string [get_long_distance_ports -dimension $dimension -ports $busports -busname $busname]
}
echo $info_string > ../../../bus_location_info
