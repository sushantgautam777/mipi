class mipi_ahb_seqr extends uvm_sequencer#(mipi_ahb_seq_item);
  `uvm_component_utils(mipi_ahb_seqr)
  
  function new(string name="mipi_ahb_seqr",uvm_component parent=null);
    super.new(name,parent);
  endfunction
endclass
