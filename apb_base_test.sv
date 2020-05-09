class apb_base_test extends uvm_test;

  `uvm_component_utils(apb_base_test)
  
  //---------------------------------------
  // env instance 
  //--------------------------------------- 
  apb_env m_env;
  apb_env_cfg    env_cfg;

  //---------------------------------------
  // constructor
  //---------------------------------------
  function new(string name = "apb_base_test",uvm_component parent=null);
    super.new(name,parent);
  endfunction : new

  //---------------------------------------
  // build_phase
  //---------------------------------------
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    // Create the env
    m_env = apb_env::type_id::create("m_env", this);
    env_cfg = apb_env_cfg::type_id::create("env_cfg", this);
  endfunction : build_phase
  
  //---------------------------------------
  // end_of_elobaration phase
  //---------------------------------------  
  virtual function void end_of_elaboration();
    //print's the topology
    print();
  endfunction

endclass : apb_base_test

class wr_rd_test extends  apb_base_test ;

  `uvm_component_utils(wr_rd_test)

  write_sequence wr_seq;
  read_sequence  rd_seq;

  function new(string name = "wr_rd_test",uvm_component parent=null);
    super.new(name,parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    // Create the seq
    wr_seq = write_sequence::type_id::create("wr_seq"); 
    //rd_seq = read_sequence::type_id::create("rd_seq");
    env_cfg.num_agents = `num_slave + 1 ;    // 1 master and 1 Slave
    //env_cfg.trans_type = apb_types:: WITHOUT_WAIT;
    env_cfg.trans_type = apb_types:: WITH_WAIT;
    uvm_config_db#(apb_env_cfg)::set(this,"*","env_cfg",env_cfg);
  endfunction : build_phase

  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    phase.raise_objection(this);
    wr_seq.start(m_env.m_agnt[0].m_sqr);
   // rd_seq.start(m_env.m_agnt[0].m_sqr);
   // wr_seq.start(m_env.m_agnt[0].m_sqr);
    #200ns;
    phase.drop_objection(this);
  endtask
  
endclass



