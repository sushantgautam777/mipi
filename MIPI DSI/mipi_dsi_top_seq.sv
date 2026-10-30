class mipi_dsi_top_seq extends uvm_sequence;

  `uvm_object_utils(mipi_dsi_top_seq)
  `uvm_declare_p_sequencer(mipi_dsi_top_seqr)
  
  mipi_ahb_seq ahb_seq1;
  mipi_dc_seq  dc_seq1;
  
  function new(string name="mipi_dsi_top_seq");
    super.new(name);
  endfunction


  task body();
    ahb_seq1 =mipi_ahb_seq::type_id::create("ahb_seq1");
    ahb_seq1.start(p_sequencer.ahb_sqr);
    dc_seq1 =mipi_dc_seq::type_id::create("dc_seq1");
    dc_seq1.start(p_sequencer.dc_sqr);
  endtask
endclass