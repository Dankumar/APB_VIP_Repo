
interface apb_if(input logic pclk,preset);

  //---------------------------------------
  //declaring the signals
  //---------------------------------------
  logic [`apb_addr_width-1:0]                  paddr  ;
  logic [`num_slave-1:0]                       psel   ;
  logic        		                             penable;
  logic        		                             pwrite ;
  logic [`apb_data_width-1:0]                  pwdata ;
  logic   [`num_slave-1:0]                     pready ;
  logic[`num_slave-1:0] [`apb_data_width-1:0]  prdata ;
  logic                                        pslverr;
  
  //Internal variables
  bit [`num_slave-1:0]  ideal_flag;
  bit [`num_slave-1:0]  setup_flag;
  bit [`num_slave-1:0]  transfer_flag;
  bit [`num_slave-1:0]  index;
  int unsigned calc_psel;
   


  always @(negedge pclk) begin
    if(preset == 1 && penable == 0 && pready == 0 && psel != 0 && (index == calc_psel)) begin
      setup_flag[calc_psel] = 1;
      ideal_flag[calc_psel] = 0;
    end
    else if(preset == 1 && penable == 1 && psel != 0 && (index == calc_psel)) begin
      setup_flag [calc_psel]= 0;
      ideal_flag [calc_psel]= 0;
      if(pready == 0) begin
        transfer_flag = 0;
      end
      else begin
        transfer_flag = 1;
      end
    end
    else if(preset == 1 && psel[calc_psel] == 0) begin
      ideal_flag [calc_psel] = 1;
    end
    else begin
      setup_flag [calc_psel] = 0;
      ideal_flag [calc_psel] = 0;
    end
  end
 
  initial begin
    paddr   = 0;
    psel    = 0;
    penable = 0;
    pwrite  = 0;
    pwdata  = 0;
    pready  = 0;
    prdata  = 0;
    pslverr = 0;
  end

  always @(psel) begin
    calc_psel = $clog2(psel);
  end
  
  
  property ideal_state;
    @(negedge pclk) disable iff(preset === 0) (psel == 0 |-> penable == 0);
  endproperty

  property setup_state;
    @(negedge pclk) disable iff(preset === 0 || setup_flag[calc_psel] == 0 || ideal_flag[calc_psel] == 1) (((psel[calc_psel] === 1) && (index == calc_psel)) |-> penable == 0);
  endproperty

  property access_state;
    @(negedge pclk) disable iff(preset === 0 || ideal_flag[calc_psel] == 1)  (((psel[calc_psel] === 1 ) && (index == calc_psel)) |=> penable == 1);
  endproperty

  property with_transfer_state;
    @(negedge pclk) disable iff(preset === 0 || transfer_flag == 1)  (((psel[calc_psel] === 1 ) && (index == calc_psel) && (penable == 1) && transfer_flag == 0) |-> pready[calc_psel] == 0);
  endproperty
    

  property without_transfer_state;
    @(negedge pclk) disable iff(preset === 0 || transfer_flag == 0 || ideal_flag[calc_psel] == 1)  (((psel[calc_psel] === 1 ) && (index == calc_psel) && (penable == 1)) |=> penable == 0 );
  endproperty

  property check_psel;
   @(posedge pclk) disable iff(preset == 0) ($countones(psel) <= 1);
  endproperty

  property check_pready;
   @(posedge pclk) disable iff(preset == 0) (pready[calc_psel] == 1 |=> pready[calc_psel] == 0);
  endproperty

  IDEAL_STATE:
    assert property (ideal_state) 
      else `uvm_error("Check",$sformatf(" Check for :: %m "));

  SETUP_STATE:
    assert property (setup_state)    
      else `uvm_error("Check",$sformatf(" Check for :: %m "));

  ACCESS_STATE:
    assert property (access_state) 
      else `uvm_error("Check",$sformatf(" Check for :: %m "));

  CHECK_PSEL:
    assert property (check_psel) 
      else `uvm_error("Check",$sformatf(" Check for :: %m "));

  CHECK_PREADY:
    assert property (check_pready)
      else `uvm_error("Check",$sformatf(" Check for :: %m "));

  WITHOUT_TRANSFER_STATE:
    assert property (without_transfer_state) 
      else `uvm_error("Check",$sformatf(" Check for :: %m "));

  WITH_TRANSFER_STATE:
    assert property (with_transfer_state) 
      else `uvm_error("Check",$sformatf(" Check for :: %m "));

endinterface
