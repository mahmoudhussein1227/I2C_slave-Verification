`ifndef MH_I2C_SCOREBOARD_SV
    `define MH_I2C_SCOREBOARD_SV

    `uvm_analysis_imp_decl(_in_model_addr)
    `uvm_analysis_imp_decl(_in_model_data)

    `uvm_analysis_imp_decl(_in_agent_addr)
    `uvm_analysis_imp_decl(_in_agent_data)

    class mh_i2c_scoreboard#(int unsigned ADDR_WIDTH = 8) extends uvm_scoreboard;

        // exp_data_resp
        uvm_tlm_fifo#(i2c_response) exp_addr_resp;
        // exp_data_resp
        uvm_tlm_fifo#(i2c_response) exp_data_resp;

        // ports to recieve the actual ack bits from the i2c_agent's monitor
        uvm_analysis_imp_in_agent_addr#(mh_i2c_item_mon#(ADDR_WIDTH) , mh_i2c_scoreboard) port_in_agent_addr;
        uvm_analysis_imp_in_agent_data#(mh_i2c_item_mon#(ADDR_WIDTH) , mh_i2c_scoreboard) port_in_agent_data;
        // ports to recieve the actual ack bits from the model
        uvm_analysis_imp_in_model_addr#(i2c_response , mh_i2c_scoreboard) port_in_model_addr;
        uvm_analysis_imp_in_model_data#(i2c_response , mh_i2c_scoreboard) port_in_model_data;

        `uvm_component_param_utils(mh_i2c_scoreboard#(ADDR_WIDTH))
        function new(string name = "" , uvm_component parent);
            super.new(name , parent);
            port_in_agent_addr = new("port_in_agent_addr" , this);
            port_in_agent_data = new("port_in_agent_data" , this);
            port_in_model_addr = new("port_in_model_addr" , this);
            port_in_model_data = new("port_in_model_data" , this);

            exp_addr_resp = new("exp_addr_resp" , this , 1);
            exp_data_resp = new("exp_data_resp" , this , 1);
        endfunction

        virtual function void write_in_agent_addr(mh_i2c_item_mon#(ADDR_WIDTH) item);
            i2c_response exp_resp;
            void'(exp_addr_resp.try_get(exp_resp));
            if(item.addr_response != exp_resp)begin
                `uvm_error("SCOREBOARD" , $sformatf("addr_resp_mismatch -> slave_addr %0h was sent and expected slave addr response : %0s (got %0s)" , 
                item.slave_addr , exp_resp.name() , item.addr_response.name()))
            end

        endfunction

        virtual function void write_in_agent_data(mh_i2c_item_mon#(ADDR_WIDTH) item);
            i2c_response exp_resp;
            void'(exp_data_resp.try_get(exp_resp));
            if(item.data_response != exp_resp)begin
                `uvm_error("SCOREBOARD" , $sformatf("there is a mismatch in data response : expected : %0s (got %0s)" , 
                exp_resp.name() , item.data_response.name()))
            end
        endfunction

        virtual function void write_in_model_addr(i2c_response exp_addr_resp);
            void'(this.exp_addr_resp.try_put(exp_addr_resp));
        endfunction

        virtual function void write_in_model_data(i2c_response exp_data_resp);
            void'(this.exp_data_resp.try_put(exp_data_resp));
        endfunction

    endclass

`endif