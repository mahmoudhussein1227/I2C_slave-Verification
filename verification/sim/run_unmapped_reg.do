#=============================================================================
# run_unmapped_reg.do - Run the unmapped-register UVM test without coverage
#=============================================================================
# Usage:  do run_unmapped_reg.do
#=============================================================================

# ---------- Quit any previous simulation ----------
quit -sim

# ---------- Directory Variables ----------
set RTL_DIR "../RTL"
set TB_DIR  "../testbench"

# ---------- Clean previous work library ----------
if {[file exists work]} {
    vdel -lib work -all
}

# ---------- Create work library ----------
vlib work
vmap work work

# ---------- Compile RTL (Verilog) ----------
vlog -work work -sv \
    $RTL_DIR/register_file.v \
    $RTL_DIR/i2c_slave_core.v \
    $RTL_DIR/i2c_peripheral_top.v

# ---------- Resolve UVM_HOME from environment ----------
if {[info exists ::env(UVM_HOME)]} {
    set UVM_HOME $::env(UVM_HOME)
} else {
    set UVM_HOME "C:/questasim64_2021.1/verilog_src/uvm-1.2"
    puts "INFO: UVM_HOME not set, using default: $UVM_HOME"
}

set QUESTA_HOME "C:/questasim64_2021.1"

# ---------- Map pre-compiled UVM library ----------
vmap mtiUvm $QUESTA_HOME/uvm-1.2

# ---------- Compile Testbench (SystemVerilog + UVM) ----------
vlog -work work -sv \
    -L mtiUvm \
    +incdir+$TB_DIR \
    +incdir+$UVM_HOME/src \
    $TB_DIR/testbench.sv

# ---------- Simulate unmapped-register test ----------
vsim -voptargs="+acc" work.testbench \
    -sv_seed random \
    +UVM_TESTNAME=mh_i2c_test_reset_ongoing \
    +UVM_VERBOSITY=UVM_MEDIUM \
    -L work \
    -L mtiUvm

# ---------- Add waves (optional — add more signals as needed) ----------
add wave -position insertpoint sim:/testbench/*
add wave -position insertpoint -group "I2C Interface" sim:/testbench/i2c_intf/*
add wave /testbench/i2c_intf/assert_data_validity
add wave /testbench/i2c_intf/assert_start_eventually_stop

# ---------- Run simulation ----------
run -all
