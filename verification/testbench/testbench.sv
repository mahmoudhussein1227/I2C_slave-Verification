//`include "mh_i2c_intf.sv" // this will removed once we include the test_pkg
`include "mh_i2c_test_pkg.sv"
module testbench();
    import uvm_pkg::*;
    import mh_i2c_test_pkg::*;

    bit clk;
    logic reset_n;
    wand sda;
    wire uvm_error_seen = mh_i2c_test_pkg::mh_i2c_test_error_seen;

    // clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10ns clock period
    end

    // interface instance
    mh_i2c_intf i2c_intf(.clk(clk));

    assign i2c_intf.reset_n = reset_n;
    assign sda = i2c_intf.sda;      // controller driver
    assign i2c_intf.sda_wand = sda; // controller monitoring signal

    // reset generation
    initial begin
        reset_n = 1;
        i2c_intf.scl = 1;
        i2c_intf.sda = 1;
        #6; 
        reset_n = 0;
        #30;
        reset_n = 1;
    end
    
    // dut instance
    i2c_peripheral_top#(.SLAVE_ADDR(7'h50)) dut(
        .clk(clk),
        .rst_n(i2c_intf.reset_n),
        .scl(i2c_intf.scl),
        .sda(sda)
    );

    initial begin
        mh_i2c_test_error_catcher error_catcher;
        error_catcher = new();
        uvm_report_cb::add(null, error_catcher);
        uvm_config_db#(virtual mh_i2c_intf)::set(null , "uvm_test_top.env.agent_master" , "vif"  , i2c_intf);
        run_test("");
    end



endmodule