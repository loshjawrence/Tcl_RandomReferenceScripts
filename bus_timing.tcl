proc get_port_timing_stats { args } {
  parse_proc_arguments -args $args results
  if { [info exists results(-dimension)] }		{ set dim $results(-dimension) } 
  if { [info exists results(-ports)] }			{ set ports $results(-ports) }
  if { [info exists results(-busname)] }		{ set busname $results(-busname) }
  set wns 20000
  set tns 0
  set total [sizeof_collection $ports]
  foreach_in_collection port $ports {
    set slack [get_attribute $port max_rise_slack]
    set fallslack [get_attribute $port max_fall_slack]
    if {$fallslack < $slack} {
      set slack $fallslack
    }
    if {$slack < $wns} {
      set wns $slack
    }
    set tns [expr $tns + $slack]
  }
  if {$total != 0} {
    set ave [expr $tns / $total]
    set return_string "$busname port timing stats:\nwns: $wns\ntns: $tns\nave slack of $busname: $ave\n"
  } else {
    set return_string "COULD NOT FIND PORTS in $busname. Size of colleciton: [sizeof_collection $ports]\n"
  }
  return $return_string
}
define_proc_attributes get_port_timing_stats \
  -info "iteratates on a bus and calculates some stats on the bus" \
  -define_args {
      {-dimension      "0 is x dimension 1 is y dimension" "" int required}
      {-ports     "handle for port collection" "" string required}
      {-busname     "bus name" "" string required}

  }

source /home/jlawrenc/*/bus_strings_*.tcl
#SET THESE PARAMETERS:
set info_string ""
#buses are aligned on which axis? 0=x, 1=y 
set dimension 1 

foreach busname $bus_strings {
  set busports [get_pins -hier -filter full_name=~*/$busname]
  set busports [add_to_collection $busports [get_pins -hier -filter full_name=~*/$busname]]
  append info_string "\n\nSize of $busname: [sizeof_collection $busports]\n"
  append info_string [get_port_timing_stats -dimension $dimension -ports $busports -busname $busname]
}
echo $info_string > ../../../bus_timing_info
