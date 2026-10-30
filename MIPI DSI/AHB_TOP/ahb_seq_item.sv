class mipi_ahb_seq_item extends uvm_sequence_item;

  rand logic [31:0] haddr;
  rand logic [31:0] hwdata;
  rand logic hwrite;
  rand logic [2:0] hsize;
  rand logic [2:0] hburst;
  rand logic [1:0] htrans;
  rand logic [3:0] hprot;
  
  `uvm_object_utils_begin(mipi_ahb_seq_item)
    `uvm_field_int(haddr , UVM_ALL_ON)
    `uvm_field_int(hwdata, UVM_ALL_ON)
    `uvm_field_int(hwrite, UVM_ALL_ON)
    `uvm_field_int(hsize , UVM_ALL_ON)
    `uvm_field_int(hburst, UVM_ALL_ON)
    `uvm_field_int(htrans, UVM_ALL_ON)
    `uvm_field_int(hprot , UVM_ALL_ON)
  `uvm_object_utils_end
  
  function new(string name="mipi_ahb_seq_item");
    super.new(name);
  endfunction
endclass
