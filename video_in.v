// Input from TV Decoder

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
					 sample_clk,
					 td_in,
					 data_out,
					 data_ready);

// I/O
input wire clkin;
input wire [7:0] td_in;
output reg [7:0] data_out;
output reg [0:0] sample_clk;
output reg [0:0] data_ready;

// General Registers
reg word_counter;
reg in_control_word;

// Sampling Registers
reg sample_counter;
reg sample_0; 
reg sample_1;
reg sample_2;
reg sample_3;
reg combined_sample;

// Data Registers
reg begin_data;

always @(posedge clkin) begin // DEMODULATOR BEGINS HERE

	// SAV/EAV Check + Auto Synchro after 1 line
	if (td_in == 'b11111111) begin
		word_counter = 0;
		in_control_word = 1;
	end
	
	// SAV/EAV Data Read
	if (in_control_word == 1 && word_counter == 3) begin
		
		in_control_word = 0;
		
		// Next word is chroma, skip it
		word_counter = 0;
	
	end

	// Normal operation - Not in sav/eav and not chroma word
	if (!in_control_word && word_counter == 1) begin
	
		sample_clk = 0; // set sample clock to LOW
		
		// Sample the luma (4x oversampling in CVBS mode)
		if (sample_counter == 0)
			sample_0 = td_in;
			
		if (sample_counter == 1)
			sample_1 = td_in;
			
		if (sample_counter == 2)
			sample_2 = td_in;
			
		if (sample_counter == 3)
			sample_3 = td_in;
		
		// Increment the counter
		sample_counter = sample_counter + 1;
		
		// Reset the counter, average the sample, tick the clock
		if (sample_counter == 4) begin
		
			sample_counter = 0;
			
			combined_sample = sample_0 + sample_1 + sample_2 + sample_3;
			combined_sample = combined_sample / 4;
			
			// READ SAMPLE ON POSITIVE EDGE OF SAMPLE CLOCK
			sample_clk = 1;
			
		end
		
		// Next word is chroma, skip it
		word_counter = 0;
		
	end

	// increment counter
	word_counter = word_counter + 1;

end // DEMODULATOR ENDS HERE


always @(posedge sample_clk) begin // DECODER BEGINS HERE

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
		
	data_out = combined_sample;
	
end // DECODER ENDS HERE

endmodule
