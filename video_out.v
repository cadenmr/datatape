// Composite output
// NOTE: Variables in this file are 1-indexed (for reasons I don't remember)

// NTSC SPECIFICATION RESOURCES:
//	 https://antiqueradio.org/art/NTSC%20Signal%20Specifications.pdf
//  http://martin.hinner.info/vga/pal.html (has NTSC section)
//	 http://www.piclist.com/techref/io/video/ntsc.htm
//	 https://www.labguysworld.com/VideoCookBook_001.htm

// INPUTS:
//  Clock 
//	 Data is ready (write decoder controls to line)
//  Data (4-bit)

// OUTPUTS:
//  Ready
//  Video out to DAC (8-bit)
//  SYNC out to DAC

module video_out(

	input wire [0:0]	rst,
	input wire [0:0]	clk,	// NTSC System Clock (6.293761309 MHz)
	
	// Output to DAC
	output reg [7:0]	video_out;
	output reg [0:0]	sync;
	
	// FIFO Data I/O
	input wire [3:0]	fifow_data,
	input wire [0:0]	fifow_clock,		// Data input clock (125 MHz from eth_mgr)
	input wire [0:0]	fifow_acknowledge,
	output wire [10:0] fifow_used_words
);
	
// Input data buffer
video_out_fifo video_output_buffer(

	.q(fifor_data)						// Read data
	.rdclk(clk),						// Read clock (6.293761309 MHz NTSC System Clock)
	.rdreq(fifor_acknowledge),		// Read acknowledge
	.rdempty(fifor_empty),			// FIFO Empty - Synchronized to read clock
	.rdusedw(fifor_used_words),	// FIFO Used words count - Synchronized to read clock
	
	.data(fifow_data), 				// Write data
	.wrclk(fifow_clk),				// Write clock (125 MHz from eth_mgr)
	.wrreq(fifow_acknowledge),		// Write acknowledge
	.wrusedw(fifow_used_words)		// FIFO Used words count - Synchronized to write clock
);

// FIFO Read Registers
wire [3:0]	fifor_data;
wire [0:0]	fifor_acknowledge;
wire [0:0]	fifor_empty;
wire [10:0]	fifor_used_words;

// Video Registers
reg [15:0] pixel_count;
reg [15:0] line_count;
reg [0:0] even_field;
reg [0:0] line_control_enabled;

// Video Output
always @(posedge clk) begin

	// Line terminator
	if (pixel_count == 401) begin
		pixel_count = 1;
		line_count = line_count + 1;
		
		if (data_in_ready)
			line_control_enabled = 1;
		else
			line_control_enabled = 0;
		
	end

	// Even field terminator
	if (even_field == 1 && line_count == 265) begin
		line_count = 1;
		pixel_count = 1;
		even_field = 0;
	end
	
	// Odd field terminator
	if (even_field == 0 && line_count == 264) begin
		pixel_count = 1;
		line_count = 1;
		even_field = 1;
	end
	
	// Equalizing Pulses -- Even Field
	if (even_field == 1 && (line_count >= 1 && line_count < 4) ||
		(line_count >= 7 && line_count < 10)) begin
		
		if (pixel_count == 1)
			sync = 0;
			
		if (pixel_count == 14) begin
			sync = 1;
			video_out = 41;
		end
			
		if (pixel_count == 200)
			sync = 0;
			
		if (pixel_count == 214) begin
			sync = 1;
			video_out = 41;
		end
		
	end
	
	// Serrated Pulses -- Even Field
	if (even_field == 1 && line_count >= 4 && line_count < 7) begin
	
		if (pixel_count == 1)
			sync = 0;
			
		if (pixel_count == 171) begin
			sync = 1;
			video_out = 41;
		end
			
		if (pixel_count == 201)
			sync = 0;
		
		if (pixel_count == 371) begin
			sync = 1;
			video_out = 41;
		end
	
	end
	
	// Blanked lines -- Even Field
	if (even_field == 1 && line_count >= 10 && line_count < 20) begin
	
		if (pixel_count == 1)
			sync = 0;
			
		if (pixel_count == 30) begin
			sync = 1;
			video_out = 41;
		end
			
	end
	
	// Active lines -- Even Field
	if (even_field == 1 && line_count >= 20 && line_count < 263) begin
		
		if (pixel_count == 1)
			sync = 0;
			
		if (pixel_count == 30) begin
			sync = 1;
			video_out = 41;
		end
		
		// Beginning of data instruction for decoder
		if (pixel_count == 58) begin
		
			if (line_control_enabled)
				video_out = 180;
			else
				video_out = 42;
			
		end
		
		// Data Stream
		if (pixel_count >= 59 && pixel_count <= 389) begin
			ready = 1;
			video_out = data_in;
		end
		
		// End Of Data instruction for decoder
		if (pixel_count == 390) begin
			ready = 0;
			
			if (line_control_enabled)
				video_out = 200;
			else
				video_out = 49;
			
		end
			
		if (pixel_count == 391)
			video_out = 41;
		
	end
	
	
	// Equalizing Pulses -- Odd field
	if (even_field == 0 && (line_count >= 1 && line_count < 3) ||
		(line_count >= 7 && line_count < 9)) begin
	
		if (pixel_count == 1)
			sync = 0;
			
		if (pixel_count == 14) begin
			sync = 1;
			video_out = 41;
		end
			
		if (pixel_count == 200)
			sync = 0;
			
		if (pixel_count == 214) begin
			sync = 1;
			video_out = 41;
		end
	
	end
	
	// Odd Field Line 3 Odd Pulse
	if (even_field == 0 && line_count == 3) begin
	
		if (pixel_count == 1)
			sync = 0;
			
		if (pixel_count == 14) begin
			sync = 1;
			video_out = 41;
		end
			
		if (pixel_count == 200)
			sync = 0;
			
		if (pixel_count == 371) begin
			sync = 1;
			video_out = 41;
		end
	
	end
	
	// Serrated Pulses -- Odd field
	if (even_field == 0 && line_count >= 4 && line_count < 6) begin
		
		if (pixel_count == 1)
			sync = 0;
			
		if (pixel_count == 171) begin
			sync = 1;
			video_out = 41;
		end
			
		if (pixel_count == 201)
			sync = 0;
		
		if (pixel_count == 371) begin
			sync = 1;
			video_out = 41;
		end
	
	end
	
	//  Odd Field Line 6 Odd Pulse
	if (even_field == 0 && line_count == 6) begin
	
		if (pixel_count == 1)
			sync = 0;
			
		if (pixel_count == 171) begin
			sync = 1;
			video_out = 41;
		end
			
		if (pixel_count == 201)
			sync = 0;
			
		if (pixel_count == 214) begin
			sync = 1;
			video_out = 41;
		end
	
	end
	
	// Odd Field Blanked Lines
	if (even_field == 0 && line_count >= 10 && line_count < 20) begin
		
		if (pixel_count == 1)
			sync = 0;
			
		if (pixel_count == 30) begin
			sync = 1;
			video_out = 41;
		end
		
	end
	
	// Active lines -- Odd Field
	if (even_field == 0 && line_count >= 20 && line_count < 263) begin
		
		if (pixel_count == 1)
			sync = 0;
			
		if (pixel_count == 30) begin
			sync = 1;
			video_out = 41;
		end
		
		// Beginning of data instruction for decoder
		if (pixel_count == 58) begin
		
			if (line_control_enabled)
				video_out = 180;
			else
				video_out = 42;
			
		end
					
		// Data Stream
		if (pixel_count >= 59 && pixel_count <= 389) begin
			ready = 1;
			video_out = data_in;
		end
		
		// End Of Data instruction for decoder
		if (pixel_count == 390) begin
			ready = 0;
			
			if (line_control_enabled)
				video_out = 200;
			else
				video_out = 49;
			
		end
			
		if (pixel_count == 391)
			video_out = 41;
		
	end
	
	// Increment pixel count every clock
	pixel_count = pixel_count + 1;

end

endmodule
