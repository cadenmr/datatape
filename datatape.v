module datatape(

	// Input Clocks
	input wire 			CLOCK_50,
	
	// User I/O
	input wire [17:0] SW,
	input wire [3:0] 	KEY,
	
	// LEDs
	output wire [7:0]  LEDG,
	output wire [17:0] LEDR,

	// Video Input
	input wire [7:0] 	TD_DATA,
	input wire 			TD_HS,
	input wire 			TD_VS,
	input wire 			TD_CLK27,
	
	// Video Output
	output wire [7:0] 	VGA_R,
	output wire [7:0] 	VGA_G,
	output wire [7:0] 	VGA_B,
	output wire 			VGA_CLK,
	output wire 			VGA_BLANK_N,
	output wire 			VGA_SYNC_N,
	
	// Ethernet
	output wire        ENET0_GTX_CLK,	// TX Clock
	output wire [3:0]  ENET0_TX_DATA,	// TX Data
	output wire        ENET0_TX_EN,		// TX CTL
	input  wire        ENET0_RX_CLK,		// RX Clock
	input  wire [3:0]  ENET0_RX_DATA,	// RX Data
	input  wire        ENET0_RX_DV		// RX CTL
);

// Reset Button
wire [0:0]	rst;
assign rst = KEY[0];

// PLL
wire [0:0]	pll_rst;
wire [0:0]	clk_ntsc;
wire [0:0]	clk_90;
wire [0:0]	clk_125;

// Output Video
reg [7:0]	output_video;
reg [0:0]	data_out_ready;
reg [7:0]	data_out;
wire [0:0]	output_ready;

// Input Video
reg [0:0] vsync;
reg [0:0] input_ready;
reg [7:0] data_in;
reg [0:0] input_sample_ready;

// Transfer between Ethernet and state_mgr
wire [7:0]	rx_data;
wire [0:0]	rx_valid;
wire [0:0]	rx_ready;
wire [0:0]	rx_last;
wire [0:0]	rx_user;
	
wire [7:0]	tx_data;
wire [0:0]	tx_ready;
wire [0:0]	tx_last;

// Video_out FIFO variables
wire [3:0]	video_out_fifor_data;
wire [0:0]	video_out_fifor_ack;
wire [0:0]	video_out_fifor_empty;
wire [8:0]	video_out_fifor_used_words;
reg [0:0]	video_out_fifow_write_request;


reg [3:0]	video_out_fifow_data;
reg [0:0]	video_out_fifow_request;
wire [8:0]	video_out_fifow_used_words;

// DAC Assignments
assign VGA_CLK = clk_ntsc; // System Pixel Clock
assign VGA_R = output_video; // Set DACs
assign VGA_G = output_video;
assign VGA_B = output_video;
assign VGA_BLANK_N = 1; // Keep BLANK set high (off)

// Modules
pll_ntsc pll0(
	pll_rst, 
	CLOCK_50, 
	clk_ntsc);
	
pll_90 pll1(
	pll_rst,
	CLOCK_50,
	clk_90);

pll_125 pll2(
	pll_rst,
	CLOCK_50,
	clk_125);

video_out_fifo video_output_buffer(

	.q(video_out_fifor_data),
	.rdclk(clk_ntsc),								// 6.293761309 MHz NTSC System Clock
	.rdreq(video_out_fifor_ack),
	.rdempty(video_out_fifor_empty),
	.rdusedw(video_out_fifor_used_words),
	
	.data(video_out_fifow_data),
	.wrclk(clk_125),								// 125 MHz Ethernet Clock
	.wrreq(video_out_fifow_write_request),
	.wrusedw(video_out_fifow_used_words)
);
	
video_out out(

	.rst(rst),
	.clk(clk_ntsc),
	
	.video_out(output_video),
	.sync(VGA_SYNC_N),
	
	.fifor_data(video_out_fifor_data),
	.fifor_acknowledge(video_our_fifor_ack),
	.fifor_empty(video_out_fifor_empty),
	.fifor_used_words(video_out_fifor_used_words)
);

video_in in(TD_CLK27, 
				input_sample_ready, 
				TD_DATA, 
				data_in,
				input_ready);
				
ethernet eth0(
	.rst(rst),
	.clk(clk_125),
	.clk90(clock_90),
	
	.rgmii_rx_clk(ENET0_RX_CLK),
	.rgmii_rx_data(ENET0_RX_DATA),
	.rgmii_rx_dv(ENET0_RX_DV),
	
	.rgmii_tx_clk(ENET0_GTX_CLK),
	.rgmii_tx_data(ENET0_TX_DATA),
	.rgmii_tx_en(ENET0_TX_EN),
	
	.rx_data(rx_data),
	.rx_ready(rx_ready)
);

state_mgr director(
	.rst(rst),
	.clk(clk_125),
	
	.rx_data(rx_data),
	.rx_ready(rx_ready),
	
	.vout_fifow_data(video_out_fifow_data),
	.vout_fifow_request(video_out_fifow_request),
	.vout_fifow_used_words(video_out_fifow_used_words)
);

endmodule
