// simple hexadecimal 7-segment display decoder
// Includes all hex characters, plus dash and underscore

// INPUTS:
//	 Clock
//	 Enable
//	 Data (8-bit)

// OUTPUTS:
//	 Display (7-bit)

module segment(clock, 
					enable, 
					display, 
					data);

// I/O
input wire clock;
input wire enable;
output reg [6:0] display;
input wire [7:0] data;

always @(posedge clock) begin

	if (enable) begin
		if (data == 'h00)
			display = 'b1000000;
			
		if (data == 'h01)
			display = 'b1111001;
			
		if (data == 'h02)
			display = 'b0100100;
			
		if (data == 'h03)
			display = 'b0110000;
		
		if (data == 'h04)
			display = 'b0011001;
		
		if (data == 'h05)
			display = 'b0010010;
		
		if (data == 'h06)
			display = 'b0000010;
		
		if (data == 'h07)
			display = 'b1111000;
		
		if (data == 'h08)
			display = 'b0000000;
		
		if (data == 'h09)
			display = 'b0010000;
			
		if (data == 'h0a)
			display = 'b0001000;
			
		if (data == 'h0b)
			display = 'b0000011;
			
		if (data == 'h0c)
			display = 'b0100111;
			
		if (data == 'h0d)
			display = 'b0100001;
			
		if (data == 'h0e)
			display = 'b0000110;
			
		if (data == 'h0f)
			display = 'b0001110;
			
		if (data == 'h10) // Dash
			display = 'b0111111;
		
		if (data == 'h20) // Underscore
			display = 'b1110111;
			
	end else
		display = 'b1111111;

end

endmodule
