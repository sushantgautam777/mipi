class mipi_ahb_agent extends uvm_agent;

  `uvm_component_utils(mipi_ahb_agent)

  mipi_ahb_drv drv;
  mipi_ahb_mon mon;
  mipi_ahb_seqr seqr;

  function new(string name="mipi_ahb_agent",uvm_component parent=null);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    drv  = mipi_ahb_drv::type_id::create("drv",this);
    mon  = mipi_ahb_mon::type_id::create("mon",this);
    seqr = mipi_ahb_seqr::type_id::create("seqr",this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    drv.seq_item_port.connect(seqr.seq_item_export);
  endfunction
endclass
