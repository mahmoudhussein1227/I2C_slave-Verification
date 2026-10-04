`ifndef MH_I2C_INTF_SV
    `define MH_I2C_INTF_SV

    interface mh_i2c_intf(input bit clk);
        logic reset_n;
        logic sda;
        logic scl;

        wand sda_wand;

        bit has_checks;
        int unsigned counter;
        bit start_detected;
        initial begin
            has_checks = 1;
        end


        task sample_start(output bit start_detected);
            forever begin
                @(negedge sda_wand);
                //`uvm_info("SAMPlE_START" , "here" , UVM_LOW)
                if(scl == 1)begin
                    start_detected = 1'b1;
                    return;
                end
                else begin
                    start_detected = 0;
                end
            end  
        endtask

        
        // assertions

        // start condition
        sequence start_condition;
            $fell(sda_wand) && scl ;
        endsequence

        // stop condtion
        sequence stop_condition;
            $rose(sda_wand) && scl ;
        endsequence

        // data validity
        property data_validity;
            @(posedge clk) disable iff(!reset_n || !has_checks)
            (start_condition) |=> (scl |-> $stable(sda_wand)) until(stop_condition or start_condition);
        endproperty

        assert_data_validity: assert property (data_validity)
            else $error("[SVA ERROR] SDA changed while SCL was HIGH during transaction!");
        cover_data_validity: cover property (data_validity);
        
        // start eventually followed by stop
        property start_eventually_stop;
            @(posedge clk) disable iff (!reset_n || !has_checks)
            start_condition |=> s_eventually stop_condition;
        endproperty
        assert_start_eventually_stop: assert property (start_eventually_stop)
            else $error("[SVA ERROR] Start condition detected but no Stop condition followed!");
        cover_start_eventually_stop: cover property (start_eventually_stop);
    endinterface

`endif


