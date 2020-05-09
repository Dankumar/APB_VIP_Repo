
class apb_sequence extends uvm_sequence#(apb_base_pkt);
  
  `uvm_object_utils(apb_sequence)
  `uvm_declare_p_sequencer(apb_sequencer)
  
  //--------------------------------------- 
  //Constructor
  //---------------------------------------
  function new(string name = "apb_sequence");
    super.new(name);
  endfunction
  
  
  //---------------------------------------
  // create, randomize and send the item to driver
  //---------------------------------------
  virtual task body();
   repeat(2) begin
    req = apb_base_pkt::type_id::create("req");
    wait_for_grant();
    req.randomize();
    send_request(req);
    wait_for_item_done();
   end 
  endtask
endclass

class apb_base_sequence extends uvm_sequence#(apb_base_pkt);
  
  `uvm_object_utils(apb_sequence)
  
  //--------------------------------------- 
  //Constructor
  //---------------------------------------
  function new(string name = "apb_sequence");
    super.new(name);
  endfunction
  
  
  //---------------------------------------
  // create, randomize and send the item to driver
  //---------------------------------------
  virtual task pre_body();
  endtask
  virtual task post_body();
  endtask
endclass

//--------------------write seuence-----------------------//

class write_sequence extends apb_base_sequence;
  
  `uvm_object_utils(write_sequence)
  `uvm_declare_p_sequencer(apb_sequencer)

   function new(string name = "write_sequence");
    super.new(name);
  endfunction

  virtual task body();
    `uvm_do_with(req, {req.pwrite  == 1;
                       req.paddr   == 'h10;
                       req.pwdata  == 'hFF;
                       })
  endtask

endclass


class read_sequence extends apb_base_sequence;
  
  `uvm_object_utils(read_sequence)
  `uvm_declare_p_sequencer(apb_sequencer)

   function new(string name = "read_sequence");
    super.new(name);
  endfunction

  virtual task body();
    `uvm_do_with(req, {req.pwrite == 0;
                       req.paddr  == 'h10;
                      })
  endtask

endclass


