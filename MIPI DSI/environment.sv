class mipi_dsi_env extends uvm_env;

  `uvm_component_utils(mipi_dsi_env)

  mipi_ahb_agent ahb_agent;
  mipi_dc_agent  dc_agent;
  mipi_ppi_agent ppi_agent;
  mipi_dsi_scoreboard sbd;
  
  mipi_ahb_cov ahb_cov;
  mipi_dc_cov dc_cov;
  mipi_ppi_cov ppi_cov;
  
  function new(string name="mipi_dsi_env",uvm_component parent=null);
    super.new(name,parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    ahb_agent =mipi_ahb_agent::type_id::create("ahb_agent",this);
    dc_agent =mipi_dc_agent::type_id::create("dc_agent",this);
    
    ppi_agent =mipi_ppi_agent::type_id::create("ppi_agent",this);
    sbd =mipi_dsi_scoreboard::type_id::create("sbd",this);
    ahb_cov=mipi_ahb_cov::type_id::create("ahb_cov",this);
    dc_cov=mipi_dc_cov::type_id::create("dc_cov",this);
    ppi_cov=mipi_ppi_cov::type_id::create("ppi_cov",this);
  endfunction
  
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    dc_agent.mon.mon_port.connect(sbd.dc_imp);
    ppi_agent.mon.ap_port.connect(sbd.ppi_imp);
    ahb_agent.mon.mon_port.connect(ahb_cov.analysis_export);
    dc_agent.mon.mon_port.connect(dc_cov.analysis_export);
    ppi_agent.mon.ap_port.connect(ppi_cov.analysis_export);
  endfunction
endclass
