class apb_env_cfg extends uvm_component;  
 
 `uvm_component_utils(apb_env_cfg)

 // Configuration for Number of Slaves and Transaction type
  rand int unsigned num_agents; 
  rand apb_types::trans trans_type;  

  //--------------------------------------- 
  // constructor
  //---------------------------------------
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  //---------------------------------------
  // build_phase - crate the components
  //---------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction : build_phase
  
endclass : apb_env_cfg
