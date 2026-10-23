class mipi_dc_seqr extends uvm_sequencer#(mipi_dc_seq_item);

  `uvm_component_utils(mipi_dc_seqr)

  function new(string name="mipi_dc_seqr",uvm_component parent=null);
    super.new(name,parent);
  endfunction
endclass