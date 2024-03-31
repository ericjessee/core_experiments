module mojo_top(
    // 50MHz clock input
    input clk,
    //avr config status
    input cclk,
    // Input from reset button (active low)
    input rst_n,
    // Outputs to the 8 onboard LEDs
    output [7:0]led,
    
    input avr_tx, // AVR Tx => FPGA Rx
    output avr_rx, // AVR Rx => FPGA Tx
    input avr_rx_busy, // AVR Rx buffer full
    output avr_rx_debug,
    output avr_tx_debug,
    output avr_rx_busy_debug
);

assign avr_rx_debug = avr_rx;
assign avr_tx_debug = avr_tx;
assign avr_rx_busy_debug = avr_rx_busy;

wire rst = ~rst_n; // make reset active high

//core connections
wire clk_419;
wire clkgen_lock;
wire clk_fb;

clk_gen_4_19 clkgen(
    .CLK_IN1(clk),
    .CLK_OUT1(clk_419),
    .RESET(rst),
    .LOCKED(clkgen_lock)
);

//cpu core
wire cpu_rst;
assign cpu_rst = rst | !clkgen_lock;

wire phi;
wire [1:0] ct;
wire [15:0] a;
wire [7:0] dout;
wire [7:0] din; //bus subordinates must go high-z when not being accessed.
wire rd;
wire wr;
reg [4:0] int_en;
reg [4:0] int_flags_in;
wire [4:0] int_flags_out;
reg [7:0] key_in;
wire done;
wire fault;

cpu cpu(
    .clk(clk_419),
    .rst(cpu_rst),
    .phi(phi),
    .ct(ct),
    .a(a),
    .din(din),
    .dout(dout),
    .rd(rd),
    .wr(wr),
    .int_en(int_en),
    .int_flags_in(int_flags_in),
    .int_flags_out(int_flags_out),
    .key_in(key_in),
    .done(done),
    .fault(fault)
);

//memory
reg rom_en;
rom_wrapper bootrom(
    .clka(clk_419),
    .rsta(cpu_rst),
    .ena(rom_en),
    .addra(a),
    .douta(din)
);

reg wram1_en;
wram_wrapper #(.BASE_ADDR(16'hc000)) wram1(
    .clka(clk_419),
    .rsta(cpu_rst),
    .ena(wram1_en),
    .wea(wr),
    .addra(a),
    .dina(dout),
    .douta(din)
);

reg wram2_en;
wram_wrapper #(.BASE_ADDR(16'hd000)) wram2(
    .clka(clk_419),
    .rsta(cpu_rst),
    .ena(wram2_en),
    .wea(wr),
    .addra(a),
    .dina(dout),
    .douta(din)
);

//peripherals
reg[7:0] led_state;
assign led = led_state;

avr_module avr_module(
    .clk(clk),
    .cclk(cclk),
    .rst(cpu_rst),
    .din(dout),
    .dout(din),
    .addr(a),
    .wr(wr),
    .rd(rd),
    .avr_rx(avr_rx),
    .avr_tx(avr_tx),
    .avr_rx_busy(avr_rx_busy)
);

always @(posedge clk) begin
    if(rst) begin
        int_en <= 0;
        int_flags_in <= 0;
        wram1_en <= 0;
        wram2_en <= 0;
        rom_en <=0;
        led_state <= 0;
    end else begin
        wram1_en <= 1;
        wram2_en <= 1;
        rom_en <=1;
        if(a == 16'hffff && wr) begin
            led_state <= dout;
        end
    end

end

endmodule
