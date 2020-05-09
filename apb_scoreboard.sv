
`uvm_analysis_imp_decl(_mstr_pkt)
`uvm_analysis_imp_decl(_slv_pkt)

class apb_scoreboard extends uvm_scoreboard;
 
  uvm_analysis_imp_mstr_pkt #(apb_base_pkt, apb_scoreboard) pkt_from_mstr;
  uvm_analysis_imp_slv_pkt #(apb_base_pkt, apb_scoreboard) pkt_from_slv;

  apb_base_pkt mstr_pkt_queue[$];
  apb_base_pkt slv_pkt_queue[$];

  int unsigned m_exp_trans;
  int unsigned m_act_trans;

  static int unsigned m_match;
  static int unsigned m_mismatch;

  //---------------------------------------
  // utilites macro for register class
  //---------------------------------------
  `uvm_component_utils(apb_scoreboard)
  
  //--------------------------------------- 
  // constructor
  //---------------------------------------
  function new(string name, uvm_component parent);
    super.new(name, parent);
    pkt_from_mstr = new("pkt_from_mstr", this);
    pkt_from_slv = new("pkt_from_slv", this);
  endfunction : new

  //---------------------------------------
  // run_phase - Start comparing master and 
  //  slave device pkt and generate report cord
  //---------------------------------------
  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    scoreboard_start_pkt_process();
  endtask : run_phase

  //---------------------------------------
  // Write APB master transaction into master queue
  //---------------------------------------
  function void write_mstr_pkt(apb_base_pkt mstr_pkt);
    apb_base_pkt pkt;
    `uvm_info(get_name(),$sformatf("APB MASTER PACKET: \n %0s \n", mstr_pkt.sprint), UVM_MEDIUM)
    pkt = apb_base_pkt::type_id::create("master_pkt", this);
    pkt.copy(mstr_pkt);
    mstr_pkt_queue.push_back(pkt);
    m_exp_trans = m_exp_trans + 1;
  endfunction

  //---------------------------------------
  // Write APB slave transaction into slave queue
  //---------------------------------------
  function void write_slv_pkt(apb_base_pkt slv_pkt);
    apb_base_pkt pkt;
    `uvm_info(get_name(),$sformatf("APB SLAVE PACKET: \n %0s \n", slv_pkt.sprint), UVM_MEDIUM)
    pkt = apb_base_pkt::type_id::create("slave_pkt", this);
    pkt.copy(slv_pkt);
    slv_pkt_queue.push_back(pkt);
    m_act_trans = m_act_trans + 1;
  endfunction

  //---------------------------------------
  // Get Master transaction queue size
  //---------------------------------------
  function int unsigned get_mstr_queue_size();
    return mstr_pkt_queue.size();
  endfunction

  //---------------------------------------
  // Get Slave transaction queue size
  //---------------------------------------
  function int unsigned get_slv_queue_size();
    return slv_pkt_queue.size();
  endfunction

  //---------------------------------------
  // Compare Master and Slave transaction
  //---------------------------------------
  task scoreboard_start_pkt_process();
    forever begin
      fork
        begin
          wait((mstr_pkt_queue.size() > 0) && (slv_pkt_queue.size() > 0));
          if((mstr_pkt_queue.size() > 0) && (slv_pkt_queue.size() > 0)) begin
            apb_base_pkt exp_pkt;
            apb_base_pkt act_pkt;
            `uvm_info(get_name(),$sformatf("APB PACKET :: ACT : %0d EXP : %0d \n", m_act_trans, m_exp_trans), UVM_MEDIUM)
            exp_pkt = mstr_pkt_queue.pop_front();
            act_pkt = slv_pkt_queue.pop_front();
            if(exp_pkt.compare(act_pkt)) begin
              `uvm_info(get_name(),$sformatf("APB PACKET MATCHES :: \n EXP : \n %0s \n ACT : \n %0s \n", exp_pkt.sprint, act_pkt.sprint), UVM_MEDIUM)
              m_match = m_match + 1;
            end
            else begin
              m_mismatch = m_mismatch + 1;
              `uvm_error(get_name(),$sformatf("APB PACKET MISMATCHES :: \n EXP : \n %0s \n ACT : \n %0s \n", exp_pkt.sprint, act_pkt.sprint))
            end
          end
        end
      join
    end
  endtask

  //---------------------------------------
  // Reporting scorecard of scoreboard
  //---------------------------------------
  virtual function void report_phase(uvm_phase phase);
    apb_base_pkt dummy_pkt;
    if(mstr_pkt_queue.size() != 0) begin
      `uvm_error(get_name(), $sformatf("APB Master queue having %0d uncompared transaction", mstr_pkt_queue.size()))
      while(mstr_pkt_queue.size() != 0) begin
        dummy_pkt = mstr_pkt_queue.pop_front();
      end
    end
    if(slv_pkt_queue.size() != 0) begin
      `uvm_error(get_name(), $sformatf("APB Slave queue having %0d uncompared transaction", slv_pkt_queue.size()))
      while(slv_pkt_queue.size() != 0) begin
        dummy_pkt = mstr_pkt_queue.pop_front();
      end
    end
    `uvm_info(get_name(),$sformatf("SCOREBOARD :: MATCH : %0d, MISMATCHES : %0d \n", this.m_match, this.m_mismatch), UVM_LOW)
  endfunction

endclass

