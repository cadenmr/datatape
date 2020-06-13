// Input from TV Decoder

// BT.656-5 Specification Resources
//	 https://www.itu.int/dms_pubrec/itu-r/rec/bt/R-REC-BT.656-5-200712-I!!PDF-E.pdf

// TODO:
//  Determine actual bit luma values

// Inputs:
//  Clock
//  TV Decoder Data In (8-bit)

// Outputs:
//  Data Out (4-bit)
//  Data Ready

// TV Decoder bitstream format:
//  Y U Y V Y U Y V (4x oversampled)

module video_in(clkin,
					 sample_ready,
					 td_in,
					 data_out,
					 data_ready);

// I/O
input wire clkin;
output reg [0:0] sample_ready;
input wire [7:0] td_in;
output reg [7:0] data_out;
output reg [0:0] data_ready;

// General Registers
reg word_counter;
reg in_control_word;

// Sampling Registers
reg [7:0] sample_counter;
reg [7:0] sample_0; 
reg [7:0] sample_1;
reg [7:0] sample_2;
reg [7:0] sample_3;
reg [31:0] combined_sample;
reg [7:0] final_sample;

// Data Registers
reg begin_data;

always @(posedge clkin) begin 
	
	sample_ready = 0;
	
	if (sample_counter == 0)
		sample_0 = td_in;
		
	else if (sample_counter == 1)
		sample_1 = td_in;
		
	else if (sample_counter == 2)
		sample_2 = td_in;
		
	else if (sample_counter == 3)
		sample_3 = td_in;
		
	else if (sample_counter == 4) begin
	
		combined_sample = sample_0 + sample_1 + sample_2 + sample_3;
		final_sample = combined_sample / 4;
		
		sample_ready = 1;
	
	end else begin
	
		sample_0 = 0;
		sample_1 = 0;
		sample_2 = 0;
		sample_3 = 0;
		sample_counter = 0;
		
	end
	
	sample_counter = sample_counter + 1;


end


always @(negedge clkin) begin

	if (sample_ready) begin

		// Determine if data is valid at the start of the sequence
		if (begin_data == 1)
			data_ready = 1;

		// Determine data from sample
		if (combined_sample >= 65 && combined_sample <= 75) begin
			begin_data = 0;
			data_out = 'b0000;
		end
			
		if (combined_sample >= 75 && combined_sample <= 85) begin
			begin_data = 0;
			data_out = 'b0001;
		end
			
		if (combined_sample >= 85 && combined_sample <= 95) begin
			begin_data = 0;
			data_out = 'b0011;
		end
			
		if (combined_sample >= 95 && combined_sample <= 105) begin
			begin_data = 0;
			data_out = 'b0111;
		end
			
		if (combined_sample >= 105 && combined_sample <= 115) begin
			begin_data = 0;
			data_out = 'b1111;
		end
			
		if (combined_sample >= 115 && combined_sample <= 125) begin
			begin_data = 0;
			data_out = 'b1110;
		end
			
		if (combined_sample >= 125 && combined_sample <= 135) begin
			begin_data = 0;
			data_out = 'b1100;
		end
			
		if (combined_sample >= 135 && combined_sample <= 145) begin
			begin_data = 0;
			data_out = 'b1000;
		end
			
		if (combined_sample >= 145 && combined_sample <= 155) begin
			begin_data = 0;
			data_out = 'b1001;
		end
			
		if (combined_sample >= 155 && combined_sample <= 165) begin
			begin_data = 0;
			data_out = 'b0110;
		end
			
		if (combined_sample >= 165 && combined_sample <= 175) begin
			begin_data = 0;
			data_out = 'b1010;
		end
			
		if (combined_sample >= 175 && combined_sample <= 185) begin
			begin_data = 0;
			data_out = 'b0101;
		end
			
		if (combined_sample >= 185 && combined_sample <= 195) begin // Begin signal
			data_out = 'b0000;
			begin_data = 1;
		end
		
		if (combined_sample >= 195 && combined_sample <= 205) begin // End signal
			data_out = 'b0000;
			begin_data = 2;
		end
		
		// Determine if data is invalid at the end of the sequence 
		if (begin_data == 2)
			data_ready = 0;
			
	end
	
end

endmodule
