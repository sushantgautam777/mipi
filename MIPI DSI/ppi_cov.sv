class mipi_ppi_cov extends uvm_subscriber#(mipi_ppi_seq_item);
  `uvm_component_utils(mipi_ppi_cov)

  mipi_ppi_seq_item tx;
  covergroup ppi_cg;
    //option.per_instance = 1;
    cp_ppi_transaction: coverpoint {
      tx.ppi_lane3_en,
      tx.ppi_lane2_en,
      tx.ppi_lane1_en,
      tx.ppi_lane0_en
    } {

      bins ppi_transaction = {
        4'b0001,
        4'b0011,
        4'b0111,
        4'b1111
      };
    }
  endgroup

  function new(string name="mipi_ppi_cov",
               uvm_component parent=null);
    super.new(name,parent);
    ppi_cg = new();
  endfunction

  function void write(mipi_ppi_seq_item t);
    tx = t;
    ppi_cg.sample();
  endfunction

  function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    $display("PPI coverage = %0.2f%%",
             ppi_cg.get_coverage());
  endfunction
endclass