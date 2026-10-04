`ifndef MH_I2C_AGENT_MASTER_CONFIG_SV
    `define MH_I2C_AGENT_MASTER_CONFIG_SV

    class mh_i2c_agent_master_config extends uvm_component;
        // vif handle
        local i2c_vif vif;
        // active_passive field
        local uvm_active_passive_enum active_passive;
        // high period duration of the scl
        local int unsigned scl_t_high;
        // low period duration of the scl
        local int unsigned scl_t_low;
        // setup_time before the posedge of the scl (SDA must be stable)
        local int unsigned t_setup;
        // hold_time after the negedge of the scl (SDA must be stable)
        local int unsigned t_hold;
        // free bus time 
        local int unsigned t_bus_f;
        // has_coverage field
        local bit has_coverage;
        // has_checks field
        local bit has_checks;

        `uvm_component_utils(mh_i2c_agent_master_config)
        function new(string name = "" , uvm_component parent);
            super.new(name , parent);
            active_passive = UVM_ACTIVE;
            scl_t_high = 4000;
            scl_t_low  = 4700;
            t_setup    = 250;
            t_hold     = 300;
            t_bus_f    = 4700;
            has_coverage = 1;
            has_checks   = 1;
        endfunction

        // vif setter
        virtual function void set_vif(i2c_vif value);
            if(vif == null)begin
                vif = value;
            end
            else begin
                `uvm_fatal("ALG_ISSUE" , "can't set the vif more than one time during the simulation")
            end
        endfunction

        //vif getter
        virtual function i2c_vif get_vif();
            return vif;
        endfunction

        // active/passive mode setter/getter
        virtual function void set_active_passive(uvm_active_passive_enum value);
            active_passive = value;
        endfunction

        virtual function uvm_active_passive_enum get_active_passive();
            return active_passive;
        endfunction

        // scl high period setter/getter
        virtual function void set_scl_t_high(int unsigned value);
            scl_t_high = value;
        endfunction

        virtual function int unsigned get_scl_t_high();
            return scl_t_high;
        endfunction

        // scl low period setter/getter
        virtual function void set_scl_t_low(int unsigned value);
            scl_t_low = value;
        endfunction

        virtual function int unsigned get_scl_t_low();
            return scl_t_low;
        endfunction

        // setup time setter/getter
        virtual function void set_t_setup(int unsigned value);
            t_setup = value;
        endfunction

        virtual function int unsigned get_t_setup();
            return t_setup;
        endfunction

        // hold time setter/getter
        virtual function void set_t_hold(int unsigned value);
            t_hold = value;
        endfunction

        virtual function int unsigned get_t_hold();
            return t_hold;
        endfunction

        // free bus time setter/getter
        virtual function void set_t_bus_f(int unsigned value);
            t_bus_f = value;
        endfunction

        virtual function int unsigned get_t_bus_f();
            return t_bus_f;
        endfunction

        virtual function void set_has_coverage(bit value);
            has_coverage = value;
        endfunction

        virtual function bit get_has_coverage();
            return has_coverage;
        endfunction

        virtual function void set_has_checks(bit value);
            has_checks = value;
        endfunction

        virtual function bit get_has_checks();
            return has_checks;
        endfunction

        // check that the vif is set before the run_phase
        virtual function void start_of_simulation_phase(uvm_phase phase);
            super.start_of_simulation_phase(phase);
            if(vif == null)begin
                `uvm_fatal("ALG_ISSUE" , "the vif can't be null at the start of simulation")
            end
            else begin
                `uvm_info("DEBUG" ,"vif is set successfully !" ,UVM_LOW)
            end
        endfunction
        
        // run_phase 
        virtual task run_phase(uvm_phase phase);
            @(vif.has_checks);
            if(vif.has_checks !== get_has_checks)begin
                `uvm_fatal("ALG_ISSUE" , "has_checks can't be modified outside the agent_config component")
            end
        endtask

        // wait_reset_start task
        virtual task wait_reset_start();
            if(vif.reset_n !== 0) begin
                @(negedge vif.reset_n);
            end
        endtask

        // wait reset_end task
        virtual task wait_reset_end();
            while(vif.reset_n == 0)begin
                @(posedge vif.clk);
            end
        endtask


    endclass

`endif