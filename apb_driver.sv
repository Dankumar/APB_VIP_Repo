
class apb_driver extends uvm_driver #(apb_base_pkt);

  //--------------------------------------- 
  // Virtual Interface
  //--------------------------------------- 
  virtual apb_if apb_vif;

  //Internal Slave select Id for Master
  int unsigned select_slave;

  //Analsys Port for Master TX
  uvm_analysis_port #(apb_base_pkt) item_drive_port;

  `uvm_component_utils(apb_driver)
    
  //--------------------------------------- 
  // Constructor
  //--------------------------------------- 
  function new (string name, uvm_component parent);
    super.new(name, parent);
    item_drive_port = new("item_drive_port", this);
  endfunction : new

  //--------------------------------------- 
  // build phase
  //---------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual apb_if)::get(this, "", "apb_intf", apb_vif))
      `uvm_fatal("NO_VIF",{"virtual interface must be set for: ",get_full_name(),".apb_vif"});
  endfunction: build_phase

  //---------------------------------------  
  // run phase
  //---------------------------------------  
  virtual task run_phase(uvm_phase phase);
    reset_signal();
    forever begin
      seq_item_port.get_next_item(req);
      item_drive_port.write(req);
      drive(req);
      seq_item_port.item_done();
    end
  endtask : run_phase

  virtual task reset_signal();
    @(negedge apb_vif.preset);
    apb_vif.psel   <= 0;
    apb_vif.penable <= 0;
    apb_vif.paddr <= 0;
    apb_vif.pwdata <= 0;
    apb_vif.pwrite <= 0;
    apb_vif.pready <= 0;
  endtask

  virtual task drive(apb_base_pkt drv_pkt);
    fork
      fork
        begin
          reset_signal();
        end
        begin 
          @(posedge apb_vif.pclk);
          apb_vif.psel    <= drv_pkt.psel;
          apb_vif.pwrite  <= drv_pkt.pwrite; 
          apb_vif.paddr   <= drv_pkt.paddr;
          apb_vif.pwdata  <= drv_pkt.pwdata;
          `uvm_info(get_full_name,$sformatf("Dankumar :: Debug :: 1st drive signals ::Master :: Driver :: Signal Information :: psel = 0x%0h, pwrite = 0x%0h, paddr = 0x%0h, pwdata = 0x%0h, penable = 0x%0h, pready = 0x%0h, prdata = 0x%0h, select_slave = 0x%0h",apb_vif.psel, apb_vif.pwrite, apb_vif.paddr, apb_vif.pwdata, apb_vif.penable, apb_vif.pready,apb_vif.prdata, select_slave),UVM_LOW);
          @(posedge apb_vif.pclk);
          `uvm_info(get_full_name,$sformatf("Dankumar :: Debug :: 2nd drive signals ::Master :: Driver :: Signal Information :: psel = 0x%0h, pwrite = 0x%0h, paddr = 0x%0h, pwdata = 0x%0h, penable = 0x%0h, pready = 0x%0h, prdata = 0x%0h, select_slave = 0x%0h",apb_vif.psel, apb_vif.pwrite, apb_vif.paddr, apb_vif.pwdata, apb_vif.penable, apb_vif.pready,apb_vif.prdata, select_slave),UVM_LOW);
          apb_vif.penable <= 1;
          //Calculate the slave ID
          select_slave = $clog2(drv_pkt.psel);
          `uvm_info(get_full_name,$sformatf("Master :: Driver :: Signal Information :: psel = 0x%0h, pwrite = 0x%0h, paddr = 0x%0h, pwdata = 0x%0h, penable = 0x%0h, pready = 0x%0h, prdata = 0x%0h, select_slave = 0x%0h",apb_vif.psel, apb_vif.pwrite, apb_vif.paddr, apb_vif.pwdata, apb_vif.penable, apb_vif.pready,apb_vif.prdata, select_slave),UVM_LOW);

          //Wait for Slave Ready
          wait(apb_vif.pready[select_slave] === 1);
          `uvm_info(get_full_name,$sformatf("Master :: Driver :: Signal Information :: psel = 0x%0h, pwrite = 0x%0h, paddr = 0x%0h, pwdata = 0x%0h, penable = 0x%0h, pready = 0x%0h, prdata = 0x%0h, select_slave = 0x%0h",apb_vif.psel, apb_vif.pwrite, apb_vif.paddr, apb_vif.pwdata, apb_vif.penable, apb_vif.pready,apb_vif.prdata, select_slave),UVM_LOW);
          @(posedge apb_vif.pclk);
          apb_vif.psel    <= 0;
          apb_vif.penable <= 0;
        end
      join_any
      disable fork;
    join
  endtask : drive

endclass : apb_driver


