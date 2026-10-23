class mipi_dc_seq_item extends uvm_sequence_item;

  rand logic data_valid;
  rand logic  [23:0] pixel_data[];
  rand int hbp;
  rand int hfp;
  rand int vbp;
  rand int vfp;
  rand int hsa;
  rand int vsa;
  
  `uvm_object_utils(mipi_dc_seq_item)
  
  function new(string name="mipi_dc_seq_item");
    super.new(name);
  endfunction
  
  constraint pixel_size_c {pixel_data.size() == `payload_cnt;}


  constraint pixel_data_range_c {foreach(pixel_data[i])pixel_data[i] inside {
        [24'h000000 : 24'hFFFFFF]};}
  
  constraint data_valid_c {data_valid == 1'b1;}
  constraint hbp_c {hbp == 4;}
  constraint hfp_c {hfp == 5;}
  constraint vbp_c {vbp == 8;}
  constraint vfp_c {vfp == 12;}
  constraint hsa_c {hsa == 2;}
  constraint vsa_c {vsa == 4;}

endclass
