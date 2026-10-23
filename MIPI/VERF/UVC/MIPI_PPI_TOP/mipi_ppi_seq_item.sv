class mipi_ppi_seq_item extends uvm_sequence_item;

  logic [7:0] ppi_data_lane0;
  logic [7:0] ppi_data_lane1;
  logic [7:0] ppi_data_lane2;
  logic [7:0] ppi_data_lane3;
  logic ppi_lane0_en;
  logic ppi_lane1_en;
  logic ppi_lane2_en;
  logic ppi_lane3_en;
  logic [7:0] payload[$];
  
  `uvm_object_utils(mipi_ppi_seq_item)
  
  function new(string name="mipi_ppi_seq_item");
    super.new(name);
  endfunction
endclass
