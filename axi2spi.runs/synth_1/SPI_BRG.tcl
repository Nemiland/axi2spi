# 
# Synthesis run script generated by Vivado
# 

set TIME_start [clock seconds] 
proc create_report { reportName command } {
  set status "."
  append status $reportName ".fail"
  if { [file exists $status] } {
    eval file delete [glob $status]
  }
  send_msg_id runtcl-4 info "Executing : $command"
  set retval [eval catch { $command } msg]
  if { $retval != 0 } {
    set fp [open $status w]
    close $fp
    send_msg_id runtcl-5 warning "$msg"
  }
}
create_project -in_memory -part xc7a100tcsg324-1

set_param project.singleFileAddWarning.threshold 0
set_param project.compositeFile.enableAutoGeneration 0
set_param synth.vivado.isSynthRun true
set_property webtalk.parent_dir C:/Users/40010377/Documents/GitHub/axi2spi/axi2spi.cache/wt [current_project]
set_property parent.project_path C:/Users/40010377/Documents/GitHub/axi2spi/axi2spi.xpr [current_project]
set_property default_lib xil_defaultlib [current_project]
set_property target_language VHDL [current_project]
set_property board_part digilentinc.com:nexys-a7-100t:part0:1.0 [current_project]
set_property ip_output_repo c:/Users/40010377/Documents/GitHub/axi2spi/axi2spi.cache/ip [current_project]
set_property ip_cache_permissions {read write} [current_project]
read_vhdl -library xil_defaultlib {
  C:/Users/40010377/Documents/GitHub/axi2spi/axi2spi.srcs/sources_1/new/AXI_IF.vhd
  C:/Users/40010377/Documents/GitHub/axi2spi/axi2spi.srcs/sources_1/new/REG_Wrapper.vhd
  C:/Users/40010377/Documents/GitHub/axi2spi/axi2spi.srcs/sources_1/new/SPI_IF.vhd
  C:/Users/40010377/Documents/GitHub/axi2spi/axi2spi.srcs/sources_1/new/SPI_BRG.vhd
  C:/Users/40010377/Documents/GitHub/axi2spi/axi2spi.srcs/sources_1/new/ipisr.vhd
  C:/Users/40010377/Documents/GitHub/axi2spi/axi2spi.srcs/sources_1/new/spisr.vhd
  C:/Users/40010377/Documents/GitHub/axi2spi/axi2spi.srcs/sources_1/new/srr.vhd
  C:/Users/40010377/Documents/GitHub/axi2spi/axi2spi.srcs/sources_1/new/rx_fifo_ocy.vhd
  C:/Users/40010377/Documents/GitHub/axi2spi/axi2spi.srcs/sources_1/new/ipier.vhd
  C:/Users/40010377/Documents/GitHub/axi2spi/axi2spi.srcs/sources_1/new/tx_fifo_ocy.vhd
  C:/Users/40010377/Documents/GitHub/axi2spi/axi2spi.srcs/sources_1/new/spicr.vhd
  C:/Users/40010377/Documents/GitHub/axi2spi/axi2spi.srcs/sources_1/new/spidtr.vhd
  C:/Users/40010377/Documents/GitHub/axi2spi/axi2spi.srcs/sources_1/new/dgier.vhd
  C:/Users/40010377/Documents/GitHub/axi2spi/axi2spi.srcs/sources_1/new/spidrr.vhd
  C:/Users/40010377/Documents/GitHub/axi2spi/axi2spi.srcs/sources_1/new/spissr.vhd
  C:/Users/40010377/Documents/GitHub/axi2spi/axi2spi.srcs/sources_1/new/SPI_Master.vhd
  C:/Users/40010377/Documents/GitHub/axi2spi/axi2spi.srcs/sources_1/new/SPI_CU.vhd
}
# Mark all dcp files as not used in implementation to prevent them from being
# stitched into the results of this synthesis run. Any black boxes in the
# design are intentionally left as such for best results. Dcp files will be
# stitched into the design at a later time, either when this synthesis run is
# opened, or when it is stitched into a dependent implementation run.
foreach dcp [get_files -quiet -all -filter file_type=="Design\ Checkpoint"] {
  set_property used_in_implementation false $dcp
}
set_param ips.enableIPCacheLiteLoad 1
close [open __synthesis_is_running__ w]

synth_design -top SPI_BRG -part xc7a100tcsg324-1


# disable binary constraint mode for synth run checkpoints
set_param constraints.enableBinaryConstraints false
write_checkpoint -force -noxdef SPI_BRG.dcp
create_report "synth_1_synth_report_utilization_0" "report_utilization -file SPI_BRG_utilization_synth.rpt -pb SPI_BRG_utilization_synth.pb"
file delete __synthesis_is_running__
close [open __synthesis_is_complete__ w]