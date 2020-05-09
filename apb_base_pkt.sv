
class apb_base_pkt extends uvm_sequence_item;

  rand bit [`apb_addr_width-1:0]   paddr;
  rand bit [`num_slave - 1:0]      psel;
  bit        		                   penable;
  rand bit        		             pwrite;
  rand bit [`apb_data_width-1:0]   pwdata;
  bit                              pready;
  bit      [`apb_data_width-1:0]   prdata;
  bit                              pslverr;
  apb_types::device_dir_e device_dir;
	  	  
  `uvm_object_utils_begin(apb_base_pkt)
      `uvm_field_int(paddr,UVM_ALL_ON)
      `uvm_field_int(psel,UVM_ALL_ON)
      `uvm_field_int(penable,UVM_ALL_ON)
      `uvm_field_int(pwrite,UVM_ALL_ON)
  	  `uvm_field_int(pwdata,UVM_ALL_ON)
  	  `uvm_field_int(pready,UVM_ALL_ON)
  	  `uvm_field_int(prdata,UVM_ALL_ON)
  	  `uvm_field_int(pslverr,UVM_ALL_ON)
      `uvm_field_enum(apb_types::device_dir_e, device_dir, UVM_DEFAULT | UVM_NOCOMPARE)
  `uvm_object_utils_end

  function new(string name = "apb_base_pkt");
      super.new(name);
  endfunction
  
  constraint one_hot_psel {
    $countones(psel) == 1;
    }

endclass:apb_base_pkt
