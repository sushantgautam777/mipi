class mipi_dsi_env extends uvm_env;
  `uvm_component_utils(mipi_dsi_env)

  mipi_ahb_agent      ahb_agent;
  mipi_dc_agent       dc_agent;
  mipi_ppi_agent      ppi_agent;
  mipi_dsi_scoreboard sbd;

  function new(string name="mipi_dsi_env", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    ahb_agent = mipi_ahb_agent::type_id::create("ahb_agent", this);
    dc_agent  = mipi_dc_agent::type_id::create("dc_agent", this);
    ppi_agent = mipi_ppi_agent::type_id::create("ppi_agent", this);
    sbd       = mipi_dsi_scoreboard::type_id::create("sbd", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    // All three monitor streams now terminate at the scoreboard.
    ahb_agent.mon.mon_port.connect(sbd.ahb_imp);
    dc_agent.mon.mon_port.connect(sbd.dc_imp);
    ppi_agent.mon.ap_port.connect(sbd.ppi_imp);
  endfunction
endclass
