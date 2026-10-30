class mipi_dsi_test extends uvm_test;

  `uvm_component_utils(mipi_dsi_test)

  mipi_dsi_env env;
  mipi_dsi_top_seqr top_sqr;
  
  function new(string name="mipi_dsi_test",uvm_component parent=null);
    super.new(name,parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env =mipi_dsi_env::type_id::create("env",this);
    top_sqr =mipi_dsi_top_seqr::type_id::create("top_sqr",this);
  endfunction
  
  task run_phase(uvm_phase phase);
    mipi_dsi_top_seq top_seq;
    phase.raise_objection(this);
    
    top_sqr.ahb_sqr =env.ahb_agent.seqr;
    top_sqr.dc_sqr =env.dc_agent.seqr;
    
    top_seq =mipi_dsi_top_seq::type_id::create("top_seq");
    top_seq.start(top_sqr);
    #20000;
    phase.drop_objection(this);
  endtask
endclass
