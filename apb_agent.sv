
class apb_agent extends uvm_agent;

  //---------------------------------------
  // component instances
  //---------------------------------------
  apb_sequencer        m_sqr;
  apb_driver           m_driver;
  apb_master_monitor   m_monitor;
  apb_slave_monitor    s_monitor;
  apb_slave_driver     s_driver;

  int unsigned device_id;

  // while declaring enum always keep a reference of a common variable type.
  apb_types::device_type_e device_type;

  `uvm_component_utils(apb_agent)
  
  //---------------------------------------
  // constructor
  //---------------------------------------
  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  //---------------------------------------
  // build_phase
  //---------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    //Set Device ID
    uvm_config_db#(int)::set(this,"*","device_id",device_id);

    //creating driver and sequencer only for ACTIVE agent
    if(get_is_active() == UVM_ACTIVE) begin
      if (device_type == apb_types::MASTER) begin
        m_driver = apb_driver::type_id::create("m_driver", this);
      end
      else if (device_type == apb_types::SLAVE)  begin
        s_driver = apb_slave_driver::type_id::create("s_driver", this);
      end
      m_sqr = apb_sequencer::type_id::create("m_sqr", this);
    end

    //creating Monitor for master and slave agents.
    if(device_type == apb_types::MASTER) begin
      m_monitor = apb_master_monitor::type_id::create("m_monitor", this);
      m_monitor.device_type = device_type;
    end
    else begin
      s_monitor = apb_slave_monitor::type_id::create("s_monitor", this);
      s_monitor.device_type = device_type;
    end

  endfunction : build_phase
  
  //---------------------------------------  
  // connect_phase - connecting the driver and sequencer port
  //---------------------------------------
  function void connect_phase(uvm_phase phase);
    if((device_type == apb_types::MASTER) && (get_is_active() == UVM_ACTIVE)) begin
      m_driver.seq_item_port.connect(m_sqr.seq_item_export);
    end
  endfunction : connect_phase

endclass : apb_agent
