class mipi_dc_cov extends uvm_subscriber#(mipi_dc_seq_item);

  `uvm_component_utils(mipi_dc_cov)

  mipi_dc_seq_item item;

  covergroup dc_cg;
    // DC transaction is valid or no 
    cp_data_valid: coverpoint item.data_valid {
      bins valid = {1'b1};
    }

   cp_pixel: coverpoint item.pixel_data[0] {
  bins zero = {24'h000000};
  bins low = {[24'h000001:24'h555555]};
  bins mid = {[24'h555556:24'hAAAAAA]};
  bins high = {[24'hAAAAAB:24'hFFFFFE]};
  bins max = {24'hFFFFFF};
}
  endgroup

  function new(string name="mipi_dc_cov",
               uvm_component parent=null);
    super.new(name,parent);
    dc_cg = new();
  endfunction

  function void write(mipi_dc_seq_item t);
    item = t;
    `uvm_info("DC_COV",
              $sformatf("DC coverage transaction: valid=%0b pixels=%0d",
                        item.data_valid,
                        item.pixel_data.size()),
              UVM_LOW)
    dc_cg.sample();
  endfunction


  function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    $display("====================================");
    $display("DC COVERAGE = %0.2f%%",
             dc_cg.get_coverage());
    $display("====================================");

  endfunction
endclass