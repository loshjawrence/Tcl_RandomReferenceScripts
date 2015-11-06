set all_reg_out [all_registers -output_pins]
set ybot 712
set ytop 1327

set flopsMID {}
foreach_in_collection outpin $all_reg_out {
  if {([lindex [get_attribute $outpin $port_attribute] 1 ] < $ytop) && ([lindex [get_attribute $outpin $port_attribute] 1 ] > $ybot)} {
   set flopsMID [add_to_collection $flopsMID $outpin] 
  }
}
 
#manually select ctl 
set ctl [get_selection]
set ctloutpins [get_pins -of $ctl -filter direction==out]
set noncontrol [remove_from_collection [all_registers -output_pins] $ctloutpins]
set flopsMID [remove_from_collection [all_registers -output_pins] $noncontrol]

set ybot 781
set ytop 1255
set splitable {}
foreach_in_collection mypin $flopsMID {
  set fanpins [all_fanout -flat -end -from $mypin]
  set flagtop 0
  set flagbot 0
  foreach_in_collection endpin $fanpins {
    if {[lindex [get_location $endpin] 1 ] > $ytop} {
      set flagtop 1
    }
    if {[lindex [get_location $endpin] 1 ] < $ybot} {
      set flagbot 1
    }
    if {$flagtop && $flagbot} {
      set splitable [add_to_collection $splitable $mypin]
      break;
    }
  }
}

foreach_in_collection pin $splitable {
  echo [get_object_name $pin]
  echo "slack: [get_attribute $pin worst_slack]"
  echo "nextslack: [get_attribute [get_pins -of [get_cells -of [all_fanout -flat -end -from $pin]] -filter {full_name=~*/Q||full_name=~*/QB}] worst_slack]\n"
} > ../../../ctlpins_slacks
