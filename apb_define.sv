//----------------to enable scoreboard-------------------//
`ifndef en_sb
  `define en_sb 1
`else
  `define en_sb en_sb
`endif

//--------------to enable coverage ---------------------//

`ifndef fun_coverage
  `define fun_coverage 1
`else
  `define fun_coverage fun_coverage
`endif

//----------to define input value which is fixed-------//

`define apb_addr_width 32
`define num_slave 4
`define apb_data_width 32


