

class apb_slave_monitor extends uvm_monitor;

  //--------------------------------------- 
  // Virtual Interface
  //--------------------------------------- 
  virtual apb_if apb_vif;

  apb_types::device_type_e device_type;
  apb_types::device_dir_e device_dir;
  int unsigned slave_id;
   apb_base_pkt pkt_out[$];

  //---------------------------------------
  // analysis port, to send the transaction to scoreboard
  //---------------------------------------
  uvm_analysis_port #(apb_base_pkt) item_collected_port;
  
  //---------------------------------------
  // The following property holds the transaction information currently
  // begin captured (by the collect_address_phase and data_phase methods).
  //---------------------------------------
  apb_base_pkt trans_collected;

  //---------------------------------------
  // utilites macro for register class
  //---------------------------------------
  `uvm_component_utils(apb_slave_monitor)

  //---------------------------------------
  // new - constructor
  //---------------------------------------
  function new (string name, uvm_component parent);
    super.new(name, parent);
    trans_collected = new();
    item_collected_port = new("item_collected_port", this);
  endfunction : new

  //---------------------------------------
  // build_phase - getting the interface handle
  //---------------------------------------
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
     if(!uvm_config_db#(virtual apb_if)::get(this, "", "apb_slave_intf", apb_vif))
       `uvm_fatal("NO_VIF",{"virtual interface must be set for: ",get_full_name(),".apb_vif"});
     if(!uvm_config_db#(int)::get(this,"*","device_id",slave_id)) 
       `uvm_fatal("NO_ID",{"ID must be set for: ",get_full_name(),"slave_id"});
  endfunction: build_phase
  

    virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    forever begin
      // Start APB packet processing
      start_pkt_processing();
      // Check queue size
      if(this.pkt_out.size() > 0) begin
        trans_collected = this.pkt_out.pop_front();
        `uvm_info(get_name(), "PUtting PKT for Analysis", UVM_LOW);
        // Putting collected packet for analysis
        item_collected_port.write(trans_collected);
      end
    end
  endtask : run_phase

  virtual task start_pkt_processing();
    fork 
      begin
        fork 
          begin
            // APB reset functionality
            @(negedge apb_vif.preset);
          end
          begin
            @(negedge apb_vif.pclk);
            if((((apb_vif.psel[slave_id - 1] === 1) && (device_type == apb_types::SLAVE))) &&
               (apb_vif.penable === 1) && (apb_vif.pready[slave_id - 1] === 1)) begin
              apb_base_pkt pkt;
              pkt = new();
              `uvm_info(get_name(), "Start Capturing packet from Interface", UVM_LOW);
              pkt.psel    = apb_vif.psel;
              pkt.paddr   = apb_vif.paddr;
              pkt.penable = apb_vif.penable;
              pkt.pready  = apb_vif.pready[slave_id - 1];
              pkt.pwrite  = apb_vif.pwrite;
              //pkt.pslverr = apb_vif.pslverr;
              if(apb_vif.pwrite === 1) begin
                pkt.pwdata  = apb_vif.pwdata;
                pkt.device_dir = apb_types::APB_RX;
              end
              else begin
                pkt.prdata  = apb_vif.prdata[slave_id - 1];
                pkt.device_dir = apb_types::APB_TX;
              end
            `uvm_info(get_full_name,$sformatf("Slave :: Monitor :: Signal Information :: psel = 0x%0h, pwrite = 0x%0h, paddr = 0x%0h, pwdata = 0x%0h, penable = 0x%0h, pready = 0x%0h, prdata = 0x%0h",pkt.psel, pkt.pwrite, pkt.paddr, pkt.pwdata, pkt.penable, pkt.pready,pkt.prdata),UVM_LOW);
              this.pkt_out.push_back(pkt); 
              `uvm_info(get_name(), "Pushing PKT into Queue", UVM_LOW);
            end
          end
        join_any
        disable fork;
      end
    join
  endtask

endclass
