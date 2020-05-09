


class apb_env extends uvm_env;
  
  //---------------------------------------
  // agent and scoreboard instance
  //---------------------------------------
  apb_agent      m_agnt[];
  apb_env_cfg    env_cfg;
  apb_scoreboard m_sb;
  
  `uvm_component_utils(apb_env)
  
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
    if(uvm_config_db#(apb_env_cfg)::get(this,"*","env_cfg",env_cfg)) begin
      m_agnt = new[env_cfg.num_agents];
      foreach(m_agnt[idx]) begin
        m_agnt[idx] = apb_agent::type_id::create($sformatf("m_agnt[%0d]",idx), this);
      end
      foreach(m_agnt[idx]) begin
        if(idx == 0) begin
          m_agnt[idx].device_type = apb_types::MASTER;  
        end
        else begin
          m_agnt[idx].device_type = apb_types::SLAVE;  
        end
        m_agnt[idx].device_id = idx;
      end
    end
    m_sb  = apb_scoreboard::type_id::create("m_sb", this);
  endfunction : build_phase
  
  //---------------------------------------
  // connect_phase - connecting monitor and scoreboard port
  //---------------------------------------
  function void connect_phase(uvm_phase phase);
    foreach(m_agnt[idx]) begin
      if(idx == 0) begin
        m_agnt[idx].m_monitor.item_collected_port.connect(m_sb.pkt_from_mstr);
      end
      else begin
        m_agnt[idx].s_monitor.item_collected_port.connect(m_sb.pkt_from_slv);
      end
    end
  endfunction : connect_phase

endclass : apb_env
