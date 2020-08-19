// Ethernet Data Parser
// Also includes state manager for project

module ethernet_parse(

	input wire [0:0]	rst,
	input wire [0:0]	clk	// Same as Ethernet clock (125 MHz)
	
	input wire [7:0]	rx_data,
	input wire [0:0]	rx_valid,
	input wire [0:0]	rx_ready,
	input wire [0:0]	rx_last,
	input wire [0:0]	rx_user,
	
	output wire [7:0]	tx_data,
	output wire [0:0]	tx_ready,
	output wire [0:0]	tx_last,
	
);

endmodule