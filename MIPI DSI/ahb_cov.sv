class mipi_ahb_cov extends uvm_subscriber#(mipi_ahb_seq_item);
  `uvm_component_utils(mipi_ahb_cov)
  mipi_ahb_seq_item item;
  //uvm_analysis_port #(mipi_ahb_seq_item,mipi_ahb_cov) analysis_export;
  covergroup ahb_cg;
    option.per_instance=1;
    
    cp_addr:coverpoint item.haddr{
      bins buffer_reg={32'h4000_0000};
      bins packet_reg={32'h4000_0004};
      bins wc_reg={32'h4000_0008};
      bins lane_reg={32'h4000_000c};
      bins ctrl_reg={32'h4000_0010};
    }
   cp_lane_cnt: coverpoint item.hwdata[1:0]
  iff (item.haddr == 32'h4000_000C) {
  
  bins one_lane   = {2'b00};
  bins two_lane   = {2'b01};
  bins three_lane = {2'b10};
  bins four_lane  = {2'b11};
}
    cross cp_addr, cp_lane_cnt;
  endgroup
    
    function new(string name="mipi_ahb_cov",uvm_component parent=null);
    super.new(name,parent);
      ahb_cg=new();
    endfunction
  
  /*function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    analysis_export=new("analysis_export",this);
  endfunction*/
  
  function void write(mipi_ahb_seq_item t);
    item = t;
    ahb_cg.sample();
    $display("ahb_coverage=%0.2ff%%",ahb_cg.get_coverage());
  endfunction
  
  function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    $display("ahb coverage = %0.2f%%", ahb_cg.get_coverage());
  endfunction
endclass
    
      