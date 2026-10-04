module register_file #(
    parameter ADDR_WIDTH = 4,
    parameter DATA_WIDTH = 8
)(
    input  wire                  clk,
    input  wire                  rst_n,
    
    // Interface from I2C Controller
    input  wire [ADDR_WIDTH-1:0] i2c_addr,     // Address from I2C pointer register
    input  wire [7:0]            i2c_addr_full,
    input  wire [DATA_WIDTH-1:0] i2c_wr_data,  // Data byte received from master
    input  wire                  i2c_wr_en,    // Pulse to commit data write
    output wire                  i2c_wr_allowed,
    output wire                  i2c_addr_mapped,
    output reg  [DATA_WIDTH-1:0] i2c_rd_data,  // Asynchronous read data to I2C engine
    
    // Application Ports (Exposed directly to external testbench or logic)
    output reg  [DATA_WIDTH-1:0] reg_0,        // Register 0x0 (e.g., Control)
    output reg  [DATA_WIDTH-1:0] reg_1,        // Register 0x1 (e.g., Config)
    output reg  [DATA_WIDTH-1:0] reg_2,        // Register 0x2 (e.g., Out Data)
    input  wire  [DATA_WIDTH-1:0] reg_3_status  // Register 0x3 (Read-Only Status Input)
);

    reg [DATA_WIDTH-1:0] reg_3_status_reg;

    assign i2c_wr_allowed = (i2c_addr == 4'h0) ||
                            (i2c_addr == 4'h1) ||
                            (i2c_addr == 4'h2);
    assign i2c_addr_mapped = (i2c_addr_full == 8'h00) ||
                             (i2c_addr_full == 8'h01) ||
                             (i2c_addr_full == 8'h02) ||
                             (i2c_addr_full == 8'h03);

    // Synchronous Writes
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            reg_0 <= 8'h00;
            reg_1 <= 8'h00;
            reg_2 <= 8'h00;
            reg_3_status_reg <= 8'h00;
        end else if (i2c_wr_en) begin
            case (i2c_addr)
                4'h0: reg_0 <= i2c_wr_data;
                4'h1: reg_1 <= i2c_wr_data;
                4'h2: reg_2 <= i2c_wr_data;
                // 4'h3 is Read-Only (Hardware Status Line)
                default: ; // Ignore writes to undefined or read-only registers
            endcase
        end
    end

    assign reg_3_status = reg_3_status_reg ;

    // Combinational Mux for Reads
    always @(*) begin
        case (i2c_addr)
            4'h0: i2c_rd_data = reg_0;
            4'h1: i2c_rd_data = reg_1;
            4'h2: i2c_rd_data = reg_2;
            4'h3: i2c_rd_data = reg_3_status;
            default: i2c_rd_data = 8'h00; // Return zero for unmapped addresses
        endcase
    end

endmodule