#=============================================================================
# run.do - QuestaSim automation script for I2C UVM Testbench
#=============================================================================
# Usage:  do run.do
# Runs all registered tests and writes coverage/merged_coverage_report.txt.
#=============================================================================

# ---------- Quit any previous simulation ----------
quit -sim

# ---------- Directory Variables ----------
set RTL_DIR      "../RTL"
set TB_DIR       "../testbench"
set COVERAGE_DIR "coverage"
set TEST_NAMES [list \
    mh_i2c_test_base \
    mh_i2c_test_unmapped_reg \
    mh_i2c_test_illegal_slave \
    mh_i2c_test_ro_reg \
    mh_i2c_test_reset_ongoing]
set COVERAGE_DATABASES [list]
set MERGED_DATABASE "$COVERAGE_DIR/merged_coverage.ucdb"
set COVERAGE_REPORT "$COVERAGE_DIR/merged_coverage_report.txt"

# ---------- Clean previous work library ----------
if {[file exists work]} {
    vdel -lib work -all
}

# ---------- Create work library ----------
vlib work
vmap work work

# ---------- Prepare coverage output ----------
file mkdir $COVERAGE_DIR
foreach TEST_NAME $TEST_NAMES {
    set DATABASE "$COVERAGE_DIR/${TEST_NAME}.ucdb"
    if {[file exists $DATABASE]} {
        file delete -force $DATABASE
    }
    lappend COVERAGE_DATABASES $DATABASE
}
foreach OUTPUT_FILE [list $MERGED_DATABASE $COVERAGE_REPORT] {
    if {[file exists $OUTPUT_FILE]} {
        file delete -force $OUTPUT_FILE
    }
}

# ---------- Compile RTL with code coverage instrumentation ----------
vlog -work work -sv -cover bcesft \
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

# ---------- Run every test and save its coverage database ----------
set TEST_SUITE_FAILED 0

foreach TEST_NAME $TEST_NAMES {
    puts "INFO: Running $TEST_NAME"
    vsim -coverage -voptargs="+acc" work.testbench \
        -sv_seed random \
        +UVM_TESTNAME=$TEST_NAME \
        +UVM_VERBOSITY=UVM_MEDIUM \
        +UVM_MAX_QUIT_COUNT=1 \
        -L work \
        -L mtiUvm

    # Return control to this script when this test calls $finish.
    onfinish stop

    # ---------- Add waves (optional — add more signals as needed) ----------
    add wave -position insertpoint sim:/testbench/*
    add wave -position insertpoint -group "I2C Interface" sim:/testbench/i2c_intf/*
    add wave /testbench/i2c_intf/assert_data_validity
    add wave /testbench/i2c_intf/assert_start_eventually_stop

    run -all
    set UVM_ERROR_SEEN [examine -radix unsigned sim:/testbench/uvm_error_seen]
    if {$UVM_ERROR_SEEN != 0} {
        puts "ERROR: $TEST_NAME reported a UVM_ERROR; stopping the test suite."
        set TEST_SUITE_FAILED 1
        quit -sim
        break
    }

    set DATABASE "$COVERAGE_DIR/${TEST_NAME}.ucdb"
    coverage save $DATABASE
    quit -sim
}

# ---------- Merge coverage only if every test passed ----------
if {$TEST_SUITE_FAILED} {
    puts "ERROR: Coverage databases were not merged because the test suite failed."
} else {
    vcover merge -out $MERGED_DATABASE {*}$COVERAGE_DATABASES
    vcover report -details -all -output $COVERAGE_REPORT $MERGED_DATABASE
    puts "INFO: Merged coverage database: $MERGED_DATABASE"
    puts "INFO: Merged coverage report: $COVERAGE_REPORT"
}
