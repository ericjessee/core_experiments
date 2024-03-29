module cpu_tb();

reg clk;
reg rst;
wire phi;
wire [1:0] ct;
wire [15:0] a;
wire [7:0] dout;
wire [7:0] din;
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

reg rom_ena;

bootrom bootrom(
    .clka(clk),
    .rsta(rst),
    .ena(rom_ena),
    .addra(a),
    .douta(din)
);

always #10 clk=~clk;

initial begin
    clk<=0;
    rom_ena<=1;
    rst<=1;
    #50
    rst<=0;
end

endmodule
