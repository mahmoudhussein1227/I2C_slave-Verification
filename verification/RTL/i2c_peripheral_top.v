module i2c_peripheral_top #(
    parameter [6:0] SLAVE_ADDR = 7'h50
)(
    input  wire       clk,
    input  wire       rst_n,
    
    // I2C Pins
    input  wire       scl,
    inout  wire       sda,
    
    // Peripheral System Pins
    output wire [7:0] ctrl_reg_0,
    output wire [7:0] cfg_reg_1,
    output wire [7:0] odata_reg_2,
    input  wire [7:0] idata_reg_3_status
);

    wire [3:0] w_addr;
    wire [7:0] w_addr_full;
    wire [7:0] w_wr_data;
    wire       w_wr_en;
    wire       w_wr_allowed;
    wire       w_addr_mapped;
    wire [7:0] w_rd_data;

    // Core protocol engine instance
    i2c_slave_core #(
        .SLAVE_ADDR(SLAVE_ADDR),
        .ADDR_WIDTH(4)
    ) u_core (
        .clk(clk),
        .rst_n(rst_n),
        .scl(scl),
        .sda(sda),
        .reg_addr(w_addr),
        .reg_addr_full(w_addr_full),
        .reg_wr_data(w_wr_data),
        .reg_wr_en(w_wr_en),
        .reg_wr_allowed(w_wr_allowed),
        .reg_addr_mapped(w_addr_mapped),
        .reg_rd_data(w_rd_data)
    );

    // Storage module instance
    register_file #(
        .ADDR_WIDTH(4),
        .DATA_WIDTH(8)
    ) u_reg_file (
        .clk(clk),
        .rst_n(rst_n),
        .i2c_addr(w_addr),
        .i2c_addr_full(w_addr_full),
        .i2c_wr_data(w_wr_data),
        .i2c_wr_en(w_wr_en),
        .i2c_wr_allowed(w_wr_allowed),
        .i2c_addr_mapped(w_addr_mapped),
        .i2c_rd_data(w_rd_data),
        .reg_0(ctrl_reg_0),
        .reg_1(cfg_reg_1),
        .reg_2(odata_reg_2),
        .reg_3_status(idata_reg_3_status)
    );

endmodule
