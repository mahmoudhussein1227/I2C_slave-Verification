`ifndef MH_I2C_SEQUENCER_SV
    `define MH_I2C_SEQUENCER_SV

    class mh_i2c_sequencer#(int unsigned ADDR_WIDTH = 2) extends uvm_sequencer#(mh_i2c_item_drv#(ADDR_WIDTH)) implements mh_i2c_reset_handler;
        `uvm_component_param_utils(mh_i2c_sequencer#(ADDR_WIDTH))
        function new(string name = "" , uvm_component parent);
            super.new(name , parent);
        endfunction

        virtual function void handle_reset(uvm_phase phase);
            int objections_count;
                stop_sequences();

                objections_count = uvm_test_done.get_objection_count(this);

                if(objections_count > 0) begin
                    uvm_test_done.drop_objection(this, $sformatf("Dropping %0d objections at reset", objections_count), objections_count);
                end
            start_phase_sequence(phase);
        
    endfunction

        
    endclass

    
`endif