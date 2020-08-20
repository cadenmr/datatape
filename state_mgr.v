// System State Manager

// Includes:
//		State manager
//		Ethernet packet parser

module state_mgr(

	input wire [0:0]	rst,
	input wire [0:0]	clk,	// Same as Ethernet clock (125 MHz)
	
	// Communication with ethernet module
	input wire [7:0]	rx_data,
	input wire [0:0]	rx_valid,
	input wire [0:0]	rx_ready,
	input wire [0:0]	rx_last,
	input wire [0:0]	rx_user,
	
	output wire [7:0]	tx_data,
	output wire [0:0]	tx_ready,
	output wire [0:0]	tx_last,
	
	// Communication with video_out
	output reg	[3:0]	vout_fifow_data,
	output wire [0:0]	vout_fifow_clock,
	output reg	[0:0]	vout_fifow_request,
	input wire [10:0]	vout_fifow_used_words
	
	// Communication with video_in
	// TBD
);

assign vout_fifow_clock = clk;	// FIFO Read clock is the same as the ethernet clock (125 MHz)

// Ethernet packat parser
reg [3:0] rx_packet_command;
reg [3:0] rx_packet_data;

always @(posedge clk) begin

	if (rx_valid && rx_ready && !rx_user) begin
	
		rx_packet_command	= rx_data[7:4];
		rx_packet_data		= rx_data[3:0];
	
	end else begin
	
		rx_packet_command	= 4'h0;
		rx_packet_data		= 4'h0;
	
	end

end

// State manager
reg [3:0]	current_state;

always @(posedge clk) begin

	case(rx_packet_command)
		default	: current_state = 4'h0;
		4'h1		: current_state = 4'h1;
	endcase

end

endmodule