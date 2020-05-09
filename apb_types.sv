class apb_types;

  typedef enum bit { MASTER , SLAVE} device_type_e;
  
  typedef enum bit { APB_TX , APB_RX} device_dir_e;


  typedef enum bit {
    WITHOUT_WAIT =1'b0,
    WITH_WAIT = 1'b1
  }trans;

endclass
