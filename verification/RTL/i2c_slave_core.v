module i2c_slave_core #(
    parameter [6:0] SLAVE_ADDR = 7'h50,
    parameter ADDR_WIDTH = 4
)(
    input  wire                  clk,
    input  wire                  rst_n,
    
    // Physical I2C Bus Pins
    input  wire                  scl,
    inout  wire                  sda,
    
    // Local Register Interconnect Bus
    output reg  [ADDR_WIDTH-1:0] reg_addr,
    output reg  [7:0]            reg_addr_full,
    output wire [7:0]            reg_wr_data,
    output reg                   reg_wr_en,
    input  wire                  reg_wr_allowed,
    input  wire                  reg_addr_mapped,
    input  wire [7:0]            reg_rd_data
);

    // Meta-stability filters
    reg scl_r0, scl_r1;
    reg sda_r0, sda_r1;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            scl_r0 <= 1'b1; scl_r1 <= 1'b1;
            sda_r0 <= 1'b1; sda_r1 <= 1'b1;
        end else begin
            scl_r0 <= scl;    scl_r1 <= scl_r0;
            sda_r0 <= sda;    sda_r1 <= sda_r0;
        end
    end

    wire start_cond = (sda_r1 && !sda_r0) && scl_r1;
    wire stop_cond  = (!sda_r1 && sda_r0) && scl_r1;
    wire scl_pos    = (scl_r0 && !scl_r1);
    wire scl_neg    = (!scl_r0 && scl_r1);

    localparam STATE_IDLE       = 3'd0,
               STATE_DEV_ADDR   = 3'd1,
               STATE_ACK_DEV    = 3'd2,
               STATE_REG_ADDR   = 3'd3,
               STATE_ACK_REG    = 3'd4,
               STATE_WRITE_DATA = 3'd5,
               STATE_READ_DATA  = 3'd6,
               STATE_ACK_DATA   = 3'd7;

    reg [2:0] state, next_state;
    reg [3:0] bit_cnt;
    reg [7:0] shift_reg;
    reg       rw_bit;   
    reg       sda_out;
    reg       sda_oe;   

    assign sda = sda_oe ? sda_out : 1'bz;
    assign reg_wr_data = shift_reg;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)          state <= STATE_IDLE;
        else if (start_cond) state <= STATE_DEV_ADDR;
        else if (stop_cond)  state <= STATE_IDLE;
        else                 state <= next_state;
    end

    always @(*) begin
        next_state = state;
        case (state)
            STATE_IDLE:       if (start_cond) next_state = STATE_DEV_ADDR;
            STATE_DEV_ADDR:   if (scl_neg && bit_cnt == 4'd8) begin
                                  if (shift_reg[7:1] == SLAVE_ADDR) next_state = STATE_ACK_DEV;
                                  else                              next_state = STATE_IDLE;
                              end
            STATE_ACK_DEV:    if (scl_neg) next_state = (rw_bit) ? STATE_READ_DATA : STATE_REG_ADDR;
            STATE_REG_ADDR:   if (scl_neg && bit_cnt == 4'd8) next_state = STATE_ACK_REG;
            STATE_ACK_REG:    if (scl_neg) next_state = reg_addr_mapped ? STATE_WRITE_DATA : STATE_IDLE;
            STATE_WRITE_DATA: if (scl_neg && bit_cnt == 4'd8) next_state = STATE_ACK_DATA;
            STATE_READ_DATA:  if (scl_neg && bit_cnt == 4'd8) next_state = STATE_ACK_DATA;
            STATE_ACK_DATA:   if (scl_neg) begin
                                  if (rw_bit) next_state = (!sda_r1) ? STATE_READ_DATA : STATE_IDLE;
                                  else        next_state = reg_wr_allowed ? STATE_WRITE_DATA : STATE_IDLE;
                              end
            default:          next_state = STATE_IDLE;
        endcase
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            bit_cnt   <= 4'd0;
            shift_reg <= 8'd0;
            reg_addr  <= {ADDR_WIDTH{1'b0}};
            reg_addr_full <= 8'd0;
            rw_bit    <= 1'b0;
            sda_out   <= 1'b1;
            sda_oe    <= 1'b0;
            reg_wr_en <= 1'b0;
         end else if (start_cond) begin
            // Reset bit counter and release SDA on START or REPEATED START
            bit_cnt   <= 4'd0;
            shift_reg <= 8'd0;
            sda_oe    <= 1'b0;
            reg_wr_en <= 1'b0;
            // Note: Do NOT clear reg_addr here, preserving the register pointer!
        end else if (stop_cond) begin
            bit_cnt   <= 4'd0;
            sda_oe    <= 1'b0;
            reg_wr_en <= 1'b0;
        end else begin
            reg_wr_en <= 1'b0; // Default pulse length
            
            case (state)
                STATE_DEV_ADDR: begin
                    sda_oe <= 1'b0;
                    if (scl_pos) begin
                        shift_reg <= {shift_reg[6:0], sda_r1};
                        bit_cnt   <= bit_cnt + 1'b1;
                    end
                    if (scl_neg && bit_cnt == 4'd8) begin
                        rw_bit  <= shift_reg[0];
                        bit_cnt <= 4'd0;
                    end
                end

                STATE_ACK_DEV: begin
                    sda_oe  <= 1'b1;
                    sda_out <= 1'b0; 
                    if (rw_bit) shift_reg <= reg_rd_data; 
                end

                STATE_REG_ADDR: begin
                    sda_oe <= 1'b0;
                    if (scl_pos) begin
                        shift_reg <= {shift_reg[6:0], sda_r1};
                        bit_cnt   <= bit_cnt + 1'b1;
                    end
                    if (scl_neg && bit_cnt == 4'd8) begin
                        reg_addr <= shift_reg[ADDR_WIDTH-1:0];
                        reg_addr_full <= shift_reg;
                        bit_cnt  <= 4'd0;
                    end
                end

                STATE_ACK_REG: begin
                    sda_oe  <= reg_addr_mapped;
                    sda_out <= 1'b0;
                end

                STATE_WRITE_DATA: begin
                    sda_oe <= 1'b0;
                    if (scl_pos) begin
                        shift_reg <= {shift_reg[6:0], sda_r1};
                        bit_cnt   <= bit_cnt + 1'b1;
                    end
                    if (scl_neg && bit_cnt == 4'd8) begin
                        if (reg_wr_allowed) reg_wr_en <= 1'b1;
                        bit_cnt   <= 4'd0;
                    end
                end

                STATE_ACK_DATA: begin
                    if (rw_bit) begin
                        sda_oe <= 1'b0;
                        if (scl_neg) begin
                            //reg_addr  <= reg_addr + 1'b1; // Auto-increment pointer for next read cycle
                            shift_reg <= reg_rd_data;
                        end
                    end else begin
                        sda_oe   <= reg_wr_allowed;
                        sda_out  <= 1'b0;
                       // if (scl_neg) reg_addr <= reg_addr + 1'b1; // Auto-increment pointer for next write cycle
                    end
                end

                STATE_READ_DATA: begin
                    sda_oe  <= 1'b1;
                    sda_out <= shift_reg[7];
                    if (scl_neg) begin
                        shift_reg <= {shift_reg[6:0], 1'b1};
                        bit_cnt   <= bit_cnt + 1'b1;
                    end
                    if (scl_neg && bit_cnt == 4'd8) begin
                        bit_cnt <= 4'd0;
                    end
                end

                default: begin
                    sda_oe  <= 1'b0;
                    bit_cnt <= 4'd0;
                end
            endcase
        end
    end
endmodule
