module cpu_tb();

reg clk;
reg rst;
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
    .clk(clk),
    .rst(rst),
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

reg rom_en;

rom_wrapper bootrom(
    .clka(clk),
    .rsta(rst),
    .ena(rom_en),
    .addra(a),
    .douta(din)
);

reg wram1_en;

wram_wrapper #(.BASE_ADDR(16'hc000)) wram1(
    .clka(clk),
    .rsta(rst),
    .ena(wram1_en),
    .wea(wr),
    .addra(a),
    .dina(dout),
    .douta(din)
);

reg wram2_en;

wram_wrapper #(.BASE_ADDR(16'hd000)) wram2(
    .clka(clk),
    .rsta(rst),
    .ena(wram2_en),
    .wea(wr),
    .addra(a),
    .dina(dout),
    .douta(din)
);

//if bit 14 and 15 not set, then in bootrom range
//assign bootrom_ena = !(a&16'hc000);
//if bit 14 and 15 are set, but not 12 and 13, then in wram1 range
//assign wram1_ena = (a&16'hc000) && !(a&16'h3000);
//if bit 12, 14, and 15 are set, but not 13, then in wram2 range
//assign wram2_ena = (a&16'hd000) && (a&2000);

//assign din = bootrom_ena ? bootrom_dout : 16'hz;
//assign din = wram1_ena ? wram1_dout : 16'hz;
//assign din = wram2_ena ? wram2_dout : 16'hz;

always #10 clk=~clk;

initial begin
    clk<=0;
    rst<=1;
    rom_en<=1;
    wram1_en<=1;
    wram2_en<=1;
    #10
    rst<=0;
    #4500
    rst<=1;
end

endmodule
