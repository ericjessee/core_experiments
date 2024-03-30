//note - BASE_ADDR must be within the range of 0-f000,
//and 12 lsb's must be 0.
//TODO - increase flexibility
module rom_wrapper #(parameter BASE_ADDR=0)(
    input            clka,
    input            rsta,
    input            ena,
    input  [15:0]    addra,
    output [7:0]     douta
);

wire [13:0] decoded_addr;
wire rom_ena;
wire [7:0] rom_out;

//address decode
assign decoded_addr = addra[13:0];
assign rom_ena = ((addra & 16'hf000) == BASE_ADDR) && ena;
assign douta = rom_ena ? rom_out : 8'hz;

bootrom bootrom(
    .clka(clka),
    .rsta(rsta),
    .ena(rom_ena),
    .addra(decoded_addr),
    .douta(rom_out)
);

endmodule
