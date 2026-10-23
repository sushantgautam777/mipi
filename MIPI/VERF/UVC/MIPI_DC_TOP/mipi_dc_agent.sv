class mipi_dc_agent extends uvm_agent;

  `uvm_component_utils(mipi_dc_agent)

  mipi_dc_drv drv;
  mipi_dc_seqr seqr;
  mipi_dc_mon mon;

  function new(string name="mipi_dc_agent",uvm_component parent=null);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    drv  = mipi_dc_drv::type_id::create("drv",this);
    mon  = mipi_dc_mon::type_id::create("mon",this);
    seqr = mipi_dc_seqr::type_id::create("seqr",this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    drv.seq_item_port.connect(seqr.seq_item_export);
  endfunction
endclass

