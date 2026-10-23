class mipi_dsi_top_seqr extends uvm_sequencer;

  `uvm_component_utils(mipi_dsi_top_seqr)
  
  mipi_ahb_seqr ahb_sqr;
  mipi_dc_seqr  dc_sqr;


  function new(string name="mipi_dsi_top_seqr",uvm_component parent=null);
    super.new(name,parent);
  endfunction
endclass