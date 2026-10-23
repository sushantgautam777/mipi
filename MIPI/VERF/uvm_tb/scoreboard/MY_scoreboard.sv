`uvm_analysis_imp_decl(_AHB)
`uvm_analysis_imp_decl(_DC)
`uvm_analysis_imp_decl(_PPI)

class mipi_dsi_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(mipi_dsi_scoreboard)

  // Analysis implementations: transactions arrive from the three monitors.
  uvm_analysis_imp_AHB #(mipi_ahb_seq_item, mipi_dsi_scoreboard) ahb_imp;
  uvm_analysis_imp_DC  #(mipi_dc_seq_item,  mipi_dsi_scoreboard) dc_imp;
  uvm_analysis_imp_PPI #(mipi_ppi_seq_item, mipi_dsi_scoreboard) ppi_imp;

  mipi_ahb_seq_item ahb_item;
  mipi_dc_seq_item  dc_item;
  mipi_ppi_seq_item ppi_item;

  // Expected pixels collected from the DC monitor; received PPI byte stream.
  bit [23:0] expected_pixels[$];
  bit [7:0]  ppi_bytes[$];

  int pass_count;
  int fail_count;

  localparam bit [7:0] START_BYTE    = 8'hAA;
  localparam bit [7:0] HEADER_MARKER = 8'hFF;
  localparam bit [7:0] END_MARKER_1  = 8'hFF;
  localparam bit [7:0] END_MARKER_2  = 8'hBB;
  localparam int PAYLOAD_LEN = `payload_cnt * 3;
  localparam int PKT_LEN     = PAYLOAD_LEN + 10;

  // --------------------------------------------------------------------------
  // AHB functional coverage (merged from ahb_cov.sv)
  // --------------------------------------------------------------------------
  covergroup ahb_cg;
    option.per_instance = 1;

    cp_addr: coverpoint ahb_item.haddr {
      bins buffer_reg = {32'h4000_0000};
      bins packet_reg = {32'h4000_0004};
      bins wc_reg     = {32'h4000_0008};
      bins lane_reg   = {32'h4000_000C};
      bins ctrl_reg   = {32'h4000_0010};
    }

    cp_lane_cnt: coverpoint ahb_item.hwdata[1:0]
      iff (ahb_item.haddr == 32'h4000_000C && ahb_item.hwrite) {
      bins one_lane   = {2'b00};
      bins two_lane   = {2'b01};
      bins three_lane = {2'b10};
      bins four_lane  = {2'b11};
    }

    // Address coverage and lane-count coverage are tracked independently.
  endgroup

  // --------------------------------------------------------------------------
  // DC functional coverage (merged from dc_cov.sv)
  // --------------------------------------------------------------------------
  covergroup dc_cg;
    option.per_instance = 1;

    cp_data_valid: coverpoint dc_item.data_valid {
      bins valid = {1'b1};
      bins invalid = {1'b0};
    }

    cp_pixel: coverpoint dc_item.pixel_data[0] iff (dc_item.pixel_data.size() > 0) {
      bins zero     = {24'h000000};
      bins non_zero = {[24'h000001:24'hFFFFFF]};
    }

    cp_pixel_count: coverpoint dc_item.pixel_data.size() {
      bins empty       = {0};
      bins one_pixel   = {1};
      bins configured  = {`payload_cnt};
      bins other_count = default;
    }
  endgroup

  // --------------------------------------------------------------------------
  // PPI lane-enable coverage (merged from ppi_cov.sv)
  // --------------------------------------------------------------------------
  covergroup ppi_cg;
    option.per_instance = 1;

    cp_lane_en: coverpoint {ppi_item.ppi_lane3_en,
                            ppi_item.ppi_lane2_en,
                            ppi_item.ppi_lane1_en,
                            ppi_item.ppi_lane0_en} {
      bins one_lane   = {4'b0001};
      bins two_lanes  = {4'b0011};
      bins three_lanes= {4'b0111};
      bins four_lanes = {4'b1111};
      illegal_bins invalid_lane_pattern = default;
    }
  endgroup

  function new(string name="mipi_dsi_scoreboard", uvm_component parent=null);
    super.new(name, parent);
    ahb_imp = new("ahb_imp", this);
    dc_imp  = new("dc_imp", this);
    ppi_imp = new("ppi_imp", this);

    ahb_cg = new();
    dc_cg  = new();
    ppi_cg = new();
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("SB", "MIPI DSI scoreboard with AHB/DC/PPI coverage created", UVM_LOW)
  endfunction

  // AHB monitor calls this method through ahb_imp.
  function void write_AHB(mipi_ahb_seq_item item);
    ahb_item = item;
    ahb_cg.sample();
    `uvm_info("SB_AHB",
      $sformatf("AHB coverage sampled: addr=%08h write=%0b data=%08h coverage=%0.2f%%",
                item.haddr, item.hwrite, item.hwdata, ahb_cg.get_coverage()), UVM_HIGH)
  endfunction

  // DC monitor calls this method through dc_imp.
  function void write_DC(mipi_dc_seq_item item);
    dc_item = item;
    dc_cg.sample();

    // This DC item represents the expected pixel transaction for the current frame.
    expected_pixels.delete();
    foreach (item.pixel_data[i])
      expected_pixels.push_back(item.pixel_data[i]);

    `uvm_info("SB_DC",
      $sformatf("DC monitor received %0d pixels; DC coverage=%0.2f%%",
                item.pixel_data.size(), dc_cg.get_coverage()), UVM_LOW)
  endfunction

  // PPI monitor calls this method through ppi_imp.
  function void write_PPI(mipi_ppi_seq_item item);
    ppi_item = item;
    ppi_cg.sample();

    // Preserve byte ordering: lane 0 byte first, then lane 1, lane 2, lane 3.
    if (item.ppi_lane0_en) ppi_bytes.push_back(item.ppi_data_lane0);
    if (item.ppi_lane1_en) ppi_bytes.push_back(item.ppi_data_lane1);
    if (item.ppi_lane2_en) ppi_bytes.push_back(item.ppi_data_lane2);
    if (item.ppi_lane3_en) ppi_bytes.push_back(item.ppi_data_lane3);

    check_packet();
  endfunction

  // Locate and check a complete packet in the accumulated PPI byte stream.
  function void check_packet();
    int start_index;
    int i;
    int pixel_count;
    bit found_start;
    bit [7:0] header_bytes[4];
    bit [7:0] payload_bytes[];
    bit [7:0] crc_bytes[2];
    bit [7:0] discarded_byte;
    bit [23:0] actual_pixel;

    if (ppi_bytes.size() < 2)
      return;

    found_start = 0;
    start_index = -1;

    // Search for AA FF packet prefix.
    for (i = 0; i < ppi_bytes.size()-1; i++) begin
      if ((ppi_bytes[i] == START_BYTE) &&
          (ppi_bytes[i+1] == HEADER_MARKER)) begin
        start_index = i;
        found_start = 1;
        break;
      end
    end

    if (!found_start)
      return;

    // Remove any bytes captured before the packet prefix.
    repeat (start_index)
      discarded_byte = ppi_bytes.pop_front();

    if (ppi_bytes.size() < PKT_LEN)
      return;

    if (ppi_bytes.pop_front() != START_BYTE) begin
      `uvm_error("SB", "Packet start byte mismatch")
      return;
    end

    if (ppi_bytes.pop_front() != HEADER_MARKER) begin
      `uvm_error("SB", "Header marker mismatch")
      return;
    end

    for (i = 0; i < 4; i++)
      header_bytes[i] = ppi_bytes.pop_front();

    payload_bytes = new[PAYLOAD_LEN];
    for (i = 0; i < PAYLOAD_LEN; i++)
      payload_bytes[i] = ppi_bytes.pop_front();

    crc_bytes[0] = ppi_bytes.pop_front();
    crc_bytes[1] = ppi_bytes.pop_front();

    if (ppi_bytes.pop_front() != END_MARKER_1) begin
      `uvm_error("SB", "First packet end marker mismatch")
      return;
    end

    if (ppi_bytes.pop_front() != END_MARKER_2) begin
      `uvm_error("SB", "Second packet end marker mismatch")
      return;
    end

    `uvm_info("SB_PACKET",
      $sformatf("Packet received: header=%02h %02h %02h %02h CRC=%02h %02h",
                header_bytes[0], header_bytes[1], header_bytes[2], header_bytes[3],
                crc_bytes[0], crc_bytes[1]), UVM_LOW)

    pixel_count = PAYLOAD_LEN / 3;
    pass_count = 0;
    fail_count = 0;

    for (i = 0; i < pixel_count; i++) begin
      actual_pixel = {payload_bytes[i*3+2], payload_bytes[i*3+1], payload_bytes[i*3]};

      if (i >= expected_pixels.size()) begin
        fail_count++;
        `uvm_error("PIXEL_CHECK",
          $sformatf("pixel[%0d] Expected=NO_DATA Actual=%06h FAIL", i, actual_pixel))
      end
      else if (actual_pixel !== expected_pixels[i]) begin
        fail_count++;
        `uvm_error("PIXEL_CHECK",
          $sformatf("pixel[%0d] Expected=%06h Actual=%06h FAIL",
                    i, expected_pixels[i], actual_pixel))
      end
      else begin
        pass_count++;
        `uvm_info("PIXEL_CHECK",
          $sformatf("pixel[%0d] Expected=%06h Actual=%06h PASS",
                    i, expected_pixels[i], actual_pixel), UVM_LOW)
      end
    end

    if (pixel_count != expected_pixels.size())
      `uvm_error("SB", $sformatf("Pixel count mismatch: expected=%0d actual=%0d",
                                  expected_pixels.size(), pixel_count))

    if ((pass_count == pixel_count) && (fail_count == 0) &&
        (pixel_count == expected_pixels.size()))
      `uvm_info("SB", $sformatf("PACKET RESULT: PASS (%0d pixels)", pass_count), UVM_LOW)
    else
      `uvm_error("SB", $sformatf("PACKET RESULT: FAIL (pass=%0d fail=%0d)",
                                 pass_count, fail_count))
  endfunction

  function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    $display("\n========== MIPI DSI SCOREBOARD COVERAGE ==========");
    $display("AHB coverage : %0.2f%%", ahb_cg.get_coverage());
    $display("DC coverage  : %0.2f%%", dc_cg.get_coverage());
    $display("PPI coverage : %0.2f%%", ppi_cg.get_coverage());
    $display("==================================================\n");
  endfunction

endclass
