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

// Transfer between Ethernet and eth_mgr
wire [7:0]	rx_data;
wire [0:0]	rx_valid;
wire [0:0]	rx_ready;
wire [0:0]	rx_last;
wire [0:0]	rx_user;
	
wire [7:0]	tx_data;
wire [0:0]	tx_ready;
wire [0:0]	tx_last;

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

video_out out(

	.rst(rst),
	.clk(clk_ntsc),
	
	.video_out(output_video),
	.sync(VGA_SYNC_N)

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
	.rx_valid(rx_valid),
	.rx_ready(rx_ready),
	.rx_last(rx_last),
	.rx_user(rx_user),
	
	.tx_data(tx_data),
	.tx_ready(tx_ready),
	.tx_last(tx_last)
);

ethernet_parse eth_mgr(
	.rst(rst),
	.clk(clk_125),
	
	.rx_data(rx_data),
	.rx_valid(rx_valid),
	.rx_ready(rx_ready),
	.rx_last(rx_last),
	.rx_user(rx_user),
	
	.tx_data(tx_data),
	.tx_ready(tx_ready),
	.tx_last(tx_last)
);

// Output Video
always @(negedge clk_ntsc) begin

end

// Input Video
always @(posedge TD_CLK27) begin

end

endmodule
