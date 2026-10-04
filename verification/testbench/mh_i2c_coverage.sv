`ifndef MH_I2C_COVERAGE_SV
    `define MH_I2C_COVERAGE_SV

    `uvm_analysis_imp_decl(_in_addr)
    `uvm_analysis_imp_decl(_in_data)
    class mh_i2c_coverage#(int unsigned ADDR_WIDTH = 2) extends uvm_component implements mh_i2c_reset_handler;
        // port_in_addr handle
        uvm_analysis_imp_in_addr#(mh_i2c_item_mon#(ADDR_WIDTH) , mh_i2c_coverage#(ADDR_WIDTH)) port_in_addr;
        // port_in_data handle
        uvm_analysis_imp_in_data#(mh_i2c_item_mon#(ADDR_WIDTH) , mh_i2c_coverage#(ADDR_WIDTH)) port_in_data;

        // i2c_access type field
        i2c_access_type access_type;
        // reg_location field
        logic [ADDR_WIDTH - 1 : 0] reg_location; 

        // start of the i2c access
        bit start;

        covergroup cover_addr with function sample(mh_i2c_item_mon#(ADDR_WIDTH) item);
            option.per_instance = 1;
            access_type : coverpoint item.access_type {

            }
            slave_addr : coverpoint item.slave_addr {
                bins slave_0 = {7'h50};
                bins illegal_slaves_0 = {[$ : 79]};
                bins illegal_slaves_1 = {[81 : $]};
            }
            addr_response : coverpoint item.addr_response {

            }

            addr_resp_x_access_type : cross access_type , addr_response;

        endgroup

        covergroup cover_data with function sample(mh_i2c_item_mon#(ADDR_WIDTH) item , i2c_access_type access , logic [ADDR_WIDTH-1:0] reg_addr);
            option.per_instance = 1;
            
            registers : coverpoint reg_addr {
                bins mapped_regs []   = {[0 : 3]};
                bins unmapped_regs = {[4:$]};
            }

            access_type : coverpoint access {

            }

            data_response : coverpoint item.data_response{

            }

            access_x_response : cross access_type , data_response {
                ignore_bins read_ack = binsof(access_type) intersect {I2C_READ} &&
                                       binsof(data_response) intersect {I2C_ACK};
            }

            access_x_reg : cross access_type , registers ;

            //registerxdata_response : cross registers , data_response;

        endgroup

        covergroup cover_reset with function sample(bit value);
            option.per_instance = 1;

            reset_on_going : coverpoint value {
                
            }

        endgroup

        `uvm_component_param_utils(mh_i2c_coverage#(ADDR_WIDTH))
        function new(string name = "" , uvm_component parent);
            super.new(name , parent);
            cover_addr   = new();
            cover_data   = new();
            cover_reset  = new();
            port_in_addr = new("port_in_addr" , this);
            port_in_data = new("port_in_data" , this);
        endfunction

        virtual function void handle_reset(uvm_phase phase);
            cover_reset.sample(start);
        endfunction

        virtual function void write_in_addr(mh_i2c_item_mon#(ADDR_WIDTH) item);
            access_type = item.access_type;
            start = 1;
            cover_addr.sample(item);
           
        endfunction

        virtual function void write_in_data(mh_i2c_item_mon#(ADDR_WIDTH) item);
            start = 0;
            if(item.access_type == I2C_WRITE) begin
                // saving the register location for the next read access
                reg_location = item.reg_location;
            end
            cover_data.sample(item , access_type , reg_location);
        endfunction

    endclass

`endif