class mipi_ppi_seqr extends uvm_sequencer#(mipi_ppi_seq_item);

  `uvm_component_utils(mipi_ppi_seqr)

  function new(string name="mipi_ppi_seqr",uvm_component parent=null);
    super.new(name,parent);
  endfunction
endclass