// System State Manager

// Includes:
//		State manager
//		Ethernet packet parser

module state_mgr(

	input wire [0:0]	rst,
	input wire [0:0]	clk,	// Same as Ethernet clock (125 MHz)
	
	// Communication with ethernet module
	input wire [7:0]	rx_data,
	input wire [0:0]	rx_ready,
	
	output wire [7:0]	tx_data,
	output wire [0:0]	tx_ready,
	output wire [0:0]	tx_last,
	
	// Communication with video_out
	output reg	[3:0]	vout_fifow_data,
	output reg	[0:0]	vout_fifow_request,
	input wire [10:0]	vout_fifow_used_words
	
	// Communication with video_in
	// TBD
);

// General Registers
reg [7:0]	system_state;		// 00:Idle, 01:Reading, 02:Writing
reg [3:0]	rx_command_reg;	// 0:None, 1:StartRead, 2:StartWrite, 3:Cancel
reg [3:0]	rx_data_reg;

// Ethernet Packet Parser (125 MHz)
always @(posedge clk) begin

	if (rx_ready) begin
	
		rx_command_reg	= rx_data[7:4];	// First four bits: Command
		rx_data_reg		= rx_data[3:0];	// Second four bits: Data
	
	end
end

// System State Manager
assign vout_fifow_clock = clk;	// FIFO Read clock is the same as the ethernet clock (125 MHz)

// Determine system state from computer, then from system modules
always @(posedge clk) begin

	// Update state from commands
	if (rx_ready) begin
		case (rx_command_reg)
			default:	system_state 	= 8'h00;				// Idle by default
			4'h0:		system_state	= system_state;	// Keep state if computer doesn't update it
			4'h1:		system_state	= 8'h01;				// Set write state
			4'h2:		system_state	= 8'h02;				// Set read state
			4'h3:		system_state	= 8'h00;				// Cancel operation and revert to idle
		endcase
	end
	
	// Idle system if reading data and fifo is exhausted
	if (system_state == 4'h2 && vout_fifow_used_words == 0) begin
		system_state	= 8'h00;
	end
	
end

// Data Director
always @(posedge clk) begin
	
	// Data Write Director
	if (system_state == 4'h1) begin
	
		// Stop writing if fifo is too full
		if (vout_fifow_used_words > 450) begin
			
			vout_fifow_request	= 1'b0;	// Stop writing to fifo
			// SEND PAUSE COMMAND TO COMPUTER HERE
			
		end else begin // Write if fifo is not too full
		
			vout_fifow_request	= 1'b1; // Begin writing to fifo
			vout_fifow_data		= rx_data;
		
		end
	end
	
	// Data Read Director
	if (system_state == 4'h2) begin
	
	
	end
end

endmodule
