`define vsync_cnt 8// Total no of Frames [Start of Frame] 

/// 10 X 5 resolution
`define hsync_cnt 5 // Start of line
`define payload_cnt 10 // 10 pixels per line [10 x 3bytes= 30 bytes per line]

typedef enum bit[2:0] { SINGLE=0,
                        INCR,
                        WRAP4,
                        INCR4,
                        WRAP8,
                        INCR8,
                        WRAP16,
                        INCR16
                      } hburst_t;

typedef enum bit[2:0] { BYTE=0,
                        HALF_WORD,
                        WORD,
                        DOUBLE_WORD,
                        FOUR_WORD_LINE,
                        EIGHT_WORD_LINE,
                        SIXTEEN_WORD_LINE,
                        THIRTY_TWO_WORD_LINE
                      } hsize_t;

typedef enum bit[1:0] { IDLE=0,
                        BUSY,
                        NONSEQ,
                        SEQ 
                      } htrans_t;


typedef enum bit[31:0] { BUFFER_REG_ADDR = 32'h4000_0000,
                         PACKET_REG_ADDR = 32'h4000_0004,
                         DSI_WC_REG_ADDR = 32'h4000_0008,
                         DSI_LANE_REG_ADDR = 32'h4000_000c,
                         CTRL_REG_ADDR = 32'h4000_0010
                       } haddr_t;

typedef enum bit { WRITE = 1,
                   READ = 0
                 } hwrite_t;

typedef enum bit[31:0] { BUFFER_DATA = 32'h0,
                         PACKET_DATA = 32'h7c,
                         WC_DATA = 32'h3c,
                         LANE_CNT_DATA = 32'h3,
                         CTRL_DATA = 32'h2
                       } hwdata_t;

class mipi_dsi_common;
endclass