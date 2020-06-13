module datatape(
	
	// Buttons
	SW,
	KEY,
	
	// Clocks
	CLOCK_50,
	
	// TV Decoder
	TD_DATA, // [7:0]
	TD_HS,
	TD_VS,
	TD_CLK27,
	
	// Composite Out
	VGA_R, // [7:0]
	VGA_G, // [7:0]
	VGA_B, // [7:0]
	VGA_CLK,
	VGA_BLANK_N,
	VGA_SYNC_N,
	
	// LEDs
	LEDG, // [7:0]
	LEDR, // [17:0]
	
	// 7 Segment Displays
	HEX0, // [6:0]
	HEX1, // [6:0]
	HEX2, // [6:0]
	HEX3, // [6:0]
	HEX4, // [6:0]
	HEX5, // [6:0]
	HEX6, // [6:0]
	HEX7, // [6:0]
	
	// Ethernet
	ENET0_GTX_CLK,
	ENET0_INT_N,
	ENET0_LINK100,
	ENET0_MDC,
	ENET0_MDIO,
	ENET0_RST_N,
	ENET0_RX_CLK,
	ENET0_RX_COL,
	ENET0_RX_CRS,
	ENET0_RX_DATA, // [3:0]
	ENET0_RX_DV,
	ENET0_RX_ER,
	ENET0_TX_CLK,
	ENET0_TX_DATA, // [3:0]
	ENET0_TX_EN,
	ENET0_TX_ER
	);
	
// I/O
input wire [17:0] SW;
input wire [3:0] KEY;

input wire CLOCK_50;

input wire [7:0] TD_DATA;
input wire TD_HS;
input wire TD_VS;
input wire TD_CLK27;

output wire [7:0] VGA_R;
output wire [7:0] VGA_G;
output wire [7:0] VGA_B;
output wire VGA_CLK;
output wire VGA_BLANK_N;
output wire VGA_SYNC_N;

output wire [7:0] LEDG;
output wire [17:0] LEDR;

output wire [6:0] HEX0;
output wire [6:0] HEX1;
output wire [6:0] HEX2;
output wire [6:0] HEX3;
output wire [6:0] HEX4;
output wire [6:0] HEX5;
output wire [6:0] HEX6;
output wire [6:0] HEX7;

output reg ENET0_GTX_CLK;
input wire ENET0_LINK100;
input wire	ENET0_INT_N;
output reg ENET0_MDC;
inout wire ENET0_MDIO;
output reg ENET0_RST_N;
input wire ENET0_RX_CLK;
input wire ENET0_RX_COL;
input wire ENET0_RX_CRS;
input wire [3:0] ENET0_RX_DATA;
input wire ENET0_RX_DV;
input wire ENET0_RX_ER;
input wire ENET0_TX_CLK;
output reg [3:0] ENET0_TX_DATA;
output reg ENET0_TX_EN;
output reg ENET0_TX_ER;

// PLL Wires
wire pll_rst;
wire output_px_clk;
wire ethernet0_clk;
wire pll_lck;

// Output Video Registers
reg [7:0] output_video;
reg [0:0] data_out_ready;
reg [7:0] data_out;
wire [0:0] output_ready;

// 7 segment registers
reg [6:0] segment_0;
reg [6:0] segment_1;
reg [6:0] segment_2;
reg [6:0] segment_3;
reg [6:0] segment_4;
reg [6:0] segment_5;
reg [6:0] segment_6;
reg [6:0] segment_7;
reg [0:0] hex_enable;

// Input Video Registers
reg [0:0] vsync;
reg [0:0] input_ready;
reg [7:0] data_in;
reg [0:0] input_sample_clk;

// Ethernet MAC Registers
wire [0:0] ethernet0_rst;
reg [7:0] ethernet0_reg_addr;
reg [31:0] ethernet0_reg_data_out;
wire [0:0] ethernet0_read;
reg [31:0] ethernet0_reg_data_in;
wire [0:0] ethernet0_write;
wire [0:0] ethernet0_busy;
wire [0:0] ethernet0_set_10;
wire [0:0] ethernet0_set_1000;
wire [0:0] ethernet0_mode;
wire [0:0] ethernet0_ena_10;
wire [0:0] ethernet0_rx_control;
wire [0:0] ethernet0_tx_control;
wire [31:0] ethernet0_rx_data;
//wire [0:0] ethernet0_rx_

// Assignments
assign VGA_CLK = output_px_clk; // System Pixel Clock
assign VGA_R = output_video; // Set DACs
assign VGA_G = output_video;
assign VGA_B = output_video;
assign VGA_BLANK_N = 1; // Keep BLANK set high (off)

// Modules
pll clocks(pll_rst, 
			  CLOCK_50, 
			  output_px_clk, 
			  ethernet0_clk, 
			  pll_lck);

video_out out(output_px_clk, 
				  data_out_ready,
				  data_out,
				  output_ready, 
				  output_video, 
				  VGA_SYNC_N);

video_in in(TD_CLK27, 
				input_sample_clk, 
				TD_DATA, 
				data_in, 
				input_ready);

// 7 segment displays
segment hex0(output_px_clk, hex_enable, HEX0[6:0], segment_0);
segment hex1(output_px_clk, hex_enable, HEX1[6:0], segment_1);
segment hex2(output_px_clk, hex_enable, HEX2[6:0], segment_2);
segment hex3(output_px_clk, hex_enable, HEX3[6:0], segment_3);
segment hex4(output_px_clk, hex_enable, HEX4[6:0], segment_4);
segment hex5(output_px_clk, hex_enable, HEX5[6:0], segment_5);
segment hex6(output_px_clk, hex_enable, HEX6[6:0], segment_6);
segment hex7(output_px_clk, hex_enable, HEX7[6:0], segment_7);

// Ethernet
//ethernet eth0(ethernet0_clk,
//						ethernet0_rst,
//						ethernet0_reg_addr[7:0],
//						ethernet0_reg_data_out[31:0],
//						ethernet0_read,
//						ethernet0_reg_data_in[31:0],
//						ethernet0_write,
//						ethernet0_busy,
//						ethernet0_clk,
//						ENET0_RX_CLK,
//						ethernet0_set_10,
//						ethernet0_set_1000,
//						ethernet0_mode,
//						ethernet0_ena_10,
//						ENET0_RX_DATA[3:0],
//						ENET0_TX_DATA[3:0],
//						ethernet0_rx_control,
//						ethernet0_tx_control,
//						ENET0_RX_CLK,
//						ethernet0_clk,
//						ethernet0_
//						

// Output Video
always @(negedge output_px_clk) begin

	// Create symbol from packet
	
	data_out = 255;
	
end

// Input Video
always @(negedge input_sample_clk && input_ready) begin

	// Create and send the packet

end

// 7 Segment Displays
always @(negedge output_px_clk) begin

	hex_enable = 1;
	segment_0 = data_out[3:0];
	segment_1 = 'he;
	segment_2 = 'hd;
	segment_3 = 'hc;
	segment_4 = 'hb;
	segment_5 = 'hb;
	segment_6 = 'ha;
	segment_7 = 'ha;

end

endmodule
