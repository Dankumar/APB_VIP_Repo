
//`timescale 1ns/1ps;

`include "uvm_macros.svh"
import uvm_pkg::*;
`include "apb_package.sv"
import apb_package::*;
`include "apb_interface.sv"


module apb_top;
  `include "apb_base_test.sv"


  bit clk;
  bit reset;
  
  always #5 clk = ~ clk;
  
  initial begin
   reset = 1;
   #5 reset = 0;
   #5 reset = 1;
  end

  //--------------------------------------- 
  //  Master and Slave Virtual Interface
  //--------------------------------------- 
  apb_if master_intf(clk,reset);
  apb_if slave_intf[`num_slave](clk,reset);


  //------------------------Dut Instance-----------------------------------//


  // Configuration for Master Interface
  initial begin
    uvm_config_db#(virtual apb_if)::set(uvm_root::get(),"*m_agnt[0].*","apb_intf",master_intf);
    assign master_intf.index = 0;
  end 

  generate
    for(genvar slv_idx=1; slv_idx <= `num_slave; slv_idx++) begin
      initial begin
        // Master to Slave Connection
        assign slave_intf[slv_idx - 1].penable  = master_intf.penable;
        assign slave_intf[slv_idx - 1].paddr    = master_intf.paddr;
        assign slave_intf[slv_idx - 1].pwrite   = master_intf.pwrite;
        assign slave_intf[slv_idx - 1].pwdata   = master_intf.pwdata;
        assign slave_intf[slv_idx - 1].psel     = master_intf.psel;
        assign slave_intf[slv_idx - 1].index    = slv_idx - 1;
  
        // Slave to Master Connection
        assign master_intf.pready[slv_idx - 1]  = slave_intf[slv_idx - 1].pready[slv_idx - 1];
        assign master_intf.prdata[slv_idx - 1]  = slave_intf[slv_idx - 1].prdata[slv_idx - 1]; 

        // Configuration for Slave Interface
        uvm_config_db#(virtual apb_if)::set(uvm_root::get(),$sformatf("*m_agnt[%0d].*", slv_idx),"apb_slave_intf",slave_intf[slv_idx - 1]);
      end
    end
  endgenerate

  initial begin
    run_test("wr_rd_test");
  end

endmodule

