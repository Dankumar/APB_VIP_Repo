class apb_slave_driver extends uvm_driver #(apb_base_pkt);

  //--------------------------------------- 
  // Virtual Interface
  //--------------------------------------- 
  virtual apb_if apb_vif;
  uvm_analysis_port #(apb_base_pkt) item_drive_port;
  `uvm_component_utils(apb_slave_driver)
  apb_base_pkt slv_pkt;

  bit[2:0] count = 2;
  //slave memory
  bit [31:0] mem[int];
  int unsigned wait_cnt; 
  apb_env_cfg    env_cfg;
  int unsigned slave_id;
  int unsigned slave_id_a;
  bit start_drive;
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
     if(!uvm_config_db#(virtual apb_if)::get(this, "", "apb_slave_intf", apb_vif))
       `uvm_fatal("NO_VIF",{"virtual interface must be set for: ",get_full_name(),".apb_vif"});
     //if(!uvm_config_db#(virtual apb_if)::get(this, "", "apb_vif", apb_vif))
     //  `uvm_fatal("NO_VIF",{"virtual interface must be set for: ",get_full_name(),".apb_vif"});
     if(!uvm_config_db#(apb_env_cfg)::get(this,"*","env_cfg",env_cfg)) 
       `uvm_fatal("NO_CFG",{"CFG must be set for: ",get_full_name(),".env_cfg"});
     if(!uvm_config_db#(int)::get(this,"*","device_id",slave_id)) 
       `uvm_fatal("NO_ID",{"ID must be set for: ",get_full_name(),"slave_id"});
  endfunction: build_phase

  //---------------------------------------  
  // run phase
  //---------------------------------------  
  virtual task run_phase(uvm_phase phase);
    reset_signal();
    forever begin
      // Wait for 2 posedge cylces: 
      // As slave driver will wait to transfer the state from IDLE to SETUP
      @(posedge apb_vif.pclk);
      @(posedge apb_vif.pclk);
      if(apb_vif.psel[slave_id - 1] == 1) begin
         start_drive = 1;
      end
      if(start_drive == 1)begin
        drive();
      end
    end
  endtask : run_phase

  virtual task reset_signal();
    @(negedge apb_vif.preset);
    apb_vif.prdata <= 0;
    apb_vif.pready <= 0;
    apb_vif.pslverr<= 0;
  endtask
 
  
  virtual task drive();
    this.wait_cnt = $urandom_range(3,10);
    fork 
      fork
        begin
          reset_signal();
        end
        begin
          //Wait for penable to start the drive process
          wait(apb_vif.penable === 1 && start_drive == 1);
          `uvm_info(get_full_name,$sformatf("Slave :: Driver :: Signal Information :: psel = 0x%0h, pwrite = 0x%0h, paddr = 0x%0h, pwdata = 0x%0h, penable = 0x%0h, pready = 0x%0h, prdata = 0x%0h",apb_vif.psel, apb_vif.pwrite, apb_vif.paddr, apb_vif.pwdata, apb_vif.penable, apb_vif.pready,apb_vif.prdata),UVM_LOW);

          //Wait for the given counts for the transaction having type
          //WITH_WAIT
          if(env_cfg.trans_type == apb_types::WITH_WAIT) begin 
            while(this.wait_cnt != 0) begin
              @(posedge apb_vif.pclk);
              this.wait_cnt = this.wait_cnt - 1;
            end
          end

          // Make Slave ready for the transaction to process and give an
          // indication to Master
            apb_vif.pready[slave_id - 1] <= 1;

          // Write data into Memory
          if(apb_vif.pwrite === 1) begin
            mem[apb_vif.paddr] = apb_vif.pwdata;
          end

          //Read data from Memory
          else begin
            bit [(`apb_data_width - 1):0] slv_rsp_data;
            slv_pkt = new();
            if(this.mem.exists(apb_vif.paddr)) begin
              //Capture the data into slave response register
              slv_rsp_data = this.mem[apb_vif.paddr];
            end
            else begin
              slv_rsp_data = 0;
            end
            slv_pkt.psel   = apb_vif.psel;
            slv_pkt.paddr  = apb_vif.paddr;
            slv_pkt.pwrite = apb_vif.pwrite;
            slv_pkt.prdata = slv_rsp_data;

            //Drive the Read data into interface
            apb_vif.prdata[slave_id - 1] <= slv_rsp_data;
            item_drive_port.write(slv_pkt);
          end 
          `uvm_info(get_full_name,$sformatf("Slave :: Driver :: Signal Information :: psel = 0x%0h, pwrite = 0x%0h, paddr = 0x%0h, pwdata = 0x%0h, penable = 0x%0h, pready = 0x%0h, prdata = 0x%0h",apb_vif.psel, apb_vif.pwrite, apb_vif.paddr, apb_vif.pwdata, apb_vif.penable, apb_vif.pready,apb_vif.prdata),UVM_LOW);
          //Wait for penable to goes low after completion of every transaction
          wait(apb_vif.penable === 0);
          apb_vif.pready[slave_id - 1] <= 0;
          start_drive = 0;
        end
        join_any
      disable fork;
    join
  endtask 
endclass




