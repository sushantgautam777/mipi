`uvm_analysis_imp_decl(_DC)
`uvm_analysis_imp_decl(_PPI)

class mipi_dsi_scoreboard extends uvm_scoreboard;

  `uvm_component_utils(mipi_dsi_scoreboard)

  uvm_analysis_imp_DC #(mipi_dc_seq_item,mipi_dsi_scoreboard) dc_imp;
  uvm_analysis_imp_PPI #(mipi_ppi_seq_item,mipi_dsi_scoreboard) ppi_imp;

  // Expected pixels from DC side
  bit [23:0] expected_pixels[$];

  // Received bytes from PPI side
  bit [7:0] ppi_bytes[$];

  // Pixel comparison counters
  int pass_count;
  int fail_count;

  parameter bit [7:0] START_BYTE    = 8'hAA;
  parameter bit [7:0] HEADER_MARKER = 8'hFF;
  parameter bit [7:0] END_MARKER_1  = 8'hFF;
  parameter bit [7:0] END_MARKER_2  = 8'hBB;

  parameter int PAYLOAD_LEN = `payload_cnt * 3;
  parameter int PKT_LEN     = PAYLOAD_LEN + 10;

  function new(string name="mipi_dsi_scoreboard",
               uvm_component parent=null);

    super.new(name,parent);

    dc_imp  = new("dc_imp",this);
    ppi_imp = new("ppi_imp",this);

  endfunction

  function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    `uvm_info("SB",
              "MIPI DSI scoreboard created",
              UVM_LOW)

  endfunction

  // Store the pixels received from the DC monitor
  function void write_DC(mipi_dc_seq_item item);

    `uvm_info("SB_DC",
              $sformatf("DC monitor received %0d pixels",
                        item.pixel_data.size()),
              UVM_LOW)

    foreach(item.pixel_data[i]) begin

      expected_pixels.push_back(item.pixel_data[i]);

    end

    `uvm_info("SB_DC",
              $sformatf("Expected pixel queue size = %0d",
                        expected_pixels.size()),
              UVM_LOW)

  endfunction

  // Collect the bytes received from the PPI monitor
  function void write_PPI(mipi_ppi_seq_item item);

    if(item.ppi_lane0_en)
      ppi_bytes.push_back(item.ppi_data_lane0);

    if(item.ppi_lane1_en)
      ppi_bytes.push_back(item.ppi_data_lane1);

    if(item.ppi_lane2_en)
      ppi_bytes.push_back(item.ppi_data_lane2);

    if(item.ppi_lane3_en)
      ppi_bytes.push_back(item.ppi_data_lane3);

    `uvm_info("SB_PPI",
              $sformatf("PPI data received, total bytes = %0d",
                        ppi_bytes.size()),
              UVM_HIGH)

    // Check whether a complete packet has arrived
    check_packet();

  endfunction

  // Find and check one complete DSI packet
  function void check_packet();

    int start_index;
    bit found_start;

    bit [7:0] header_bytes[4];
    bit [7:0] payload_bytes[];
    bit [7:0] crc_bytes[2];

    bit [23:0] actual_pixel;

    int pixel_count;
    int i;

    if(ppi_bytes.size() < 2)
      return;

    found_start = 0;
    start_index = -1;

    // Search for packet start: AA FF
    for(i=0;i<ppi_bytes.size()-1;i++) begin

      if((ppi_bytes[i] == START_BYTE) &&
         (ppi_bytes[i+1] == HEADER_MARKER)) begin

        start_index = i;
        found_start = 1;

        `uvm_info("SB_CHECK",
                  $sformatf("PACKET START FOUND at index %0d",
                            start_index),
                  UVM_HIGH)

        break;

      end

    end

    if(!found_start) begin

      `uvm_info("SB_CHECK",
                "PACKET START NOT FOUND",
                UVM_HIGH)

      return;

    end

    // Remove bytes before the packet start
    if(start_index > 0) begin

      repeat(start_index)
        void'(ppi_bytes.pop_front());

    end

    // Wait until the complete packet is available
    if(ppi_bytes.size() < PKT_LEN) begin

      `uvm_info("SB_CHECK",
                $sformatf("PACKET INCOMPLETE: received=%0d required=%0d",
                          ppi_bytes.size(),
                          PKT_LEN),
                UVM_HIGH)

      return;

    end

    // Check packet start byte
    if(ppi_bytes.pop_front() != START_BYTE) begin

      `uvm_error("SB",
                 "START BYTE mismatch")

      return;

    end

    // Check header marker
    if(ppi_bytes.pop_front() != HEADER_MARKER) begin

      `uvm_error("SB",
                 "HEADER marker mismatch")

      return;

    end

    // Extract 4 header bytes
    for(i=0;i<4;i++)
      header_bytes[i] = ppi_bytes.pop_front();

    `uvm_info("SB",
              $sformatf("Received HEADER = %02h %02h %02h %02h",
                        header_bytes[0],
                        header_bytes[1],
                        header_bytes[2],
                        header_bytes[3]),
              UVM_LOW)

    // Extract complete pixel payload
    payload_bytes = new[PAYLOAD_LEN];

    for(i=0;i<PAYLOAD_LEN;i++)
      payload_bytes[i] = ppi_bytes.pop_front();

    // Extract CRC
    crc_bytes[0] = ppi_bytes.pop_front();
    crc_bytes[1] = ppi_bytes.pop_front();

    `uvm_info("SB",
              $sformatf("Received CRC = %02h %02h",
                        crc_bytes[0],
                        crc_bytes[1]),
              UVM_LOW)

    // Check packet end markerr if we want to check we can check ,, but useless here ,, 
/*    if(ppi_bytes.pop_front() != END_MARKER_1) begin

      `uvm_error("SB",
                 "First END marker mismatch")

      return;

    end

    if(ppi_bytes.pop_front() != END_MARKER_2) begin

      `uvm_error("SB",
                 "Second END marker mismatch")

      return;

    end
*/
    pixel_count = PAYLOAD_LEN / 3;

    `uvm_info("SB",
              $sformatf("Received payload contains %0d pixels",
                        pixel_count),
              UVM_LOW)

    // Reset counters for this packet
    pass_count = 0;
    fail_count = 0;

    // Compare every PPI pixel with the DC pixel
    for(i=0;i<pixel_count;i++) begin

      // Three bytes from PPI make one 24-bit RGB pixel
      actual_pixel = {
        payload_bytes[i*3+2],
        payload_bytes[i*3+1],
        payload_bytes[i*3+0]
      };

      // No expected pixel available
      if(i >= expected_pixels.size()) begin

        fail_count++;

        `uvm_error("PIXEL_CHECK",
                   $sformatf("pixel[%0d] Expected=NO_DATA Actual=%06h FAIL",
                             i,
                             actual_pixel))

      end

      // Expected and actual pixel are different
      else if(actual_pixel !== expected_pixels[i]) begin

        fail_count++;

        `uvm_error("PIXEL_CHECK",
                   $sformatf("pixel[%0d] Expected=%06h Actual=%06h FAIL",
                             i,
                             expected_pixels[i],
                             actual_pixel))

      end

      // Pixel matches
      else begin

        pass_count++;

        `uvm_info("PIXEL_CHECK",
                  $sformatf("pixel[%0d] Expected=%06h Actual=%06h PASS",
                            i,
                            expected_pixels[i],
                            actual_pixel),
                  UVM_LOW)

      end

    end

    // Check whether expected and received pixel counts are equal
    if(pixel_count != expected_pixels.size()) begin

      `uvm_error("SB",
                 $sformatf("PIXEL COUNT MISMATCH: Expected=%0d Actual=%0d",
                           expected_pixels.size(),
                           pixel_count))

    end

    // Final comparison result
    `uvm_info("SB",
              $sformatf("TOTAL PIXELS : %0d",
                        pixel_count),
              UVM_LOW)

    `uvm_info("SB",
              $sformatf("PASS COUNT   : %0d",
                        pass_count),
              UVM_LOW)

    `uvm_info("SB",
              $sformatf("FAIL COUNT   : %0d",
                        fail_count),
              UVM_LOW)

    if((pass_count == pixel_count) &&
       (fail_count == 0) &&
       (pixel_count == expected_pixels.size())) begin

      `uvm_info("SB",
                "RESULT       : PASS",
                UVM_LOW)

    end
    else begin

      `uvm_error("SB",
                 "RESULT       : FAIL")

    end

  endfunction

endclass