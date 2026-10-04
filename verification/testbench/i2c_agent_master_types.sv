`ifndef MH_I2C_AGENT_MASTER_TYPES_SV
    `define MH_I2C_AGENT_MASTER_TYPES_SV

    typedef virtual mh_i2c_intf i2c_vif;
    typedef enum bit {I2C_ACK , I2C_NACK} i2c_response;
    typedef enum bit { I2C_WRITE , I2C_READ} i2c_access_type;

`endif