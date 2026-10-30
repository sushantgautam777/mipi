class mipi_ppi_agent extends uvm_agent;

  `uvm_component_utils(mipi_ppi_agent)
  mipi_ppi_monitor mon;


  function new(string name="mipi_ppi_agent",uvm_component parent=null);
    super.new(name,parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    mon =mipi_ppi_monitor::type_id::create("mon",this);
  endfunction
endclass