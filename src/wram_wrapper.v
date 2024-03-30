//note - BASE_ADDR must be within the range of 0-f000,
//and 12 lsb's must be 0.
//TODO - increase flexibility
module wram_wrapper #(parameter BASE_ADDR=0)(
    input            clka,
    input            rsta,
    input            ena,
    input            wea,
    input  [15:0]    addra,
    input  [7:0]     dina,
    output [7:0]     douta
);

wire [13:0] decoded_addr;
wire wram_ena;
wire [7:0] wram_out;

//address decode
assign decoded_addr = addra[13:0];
assign wram_ena = ((addra & 16'hf000) == BASE_ADDR) && ena;
assign douta = wram_ena ? wram_out : 8'hz;

wram wram(
    .clka(clka),
    .rsta(rsta),
    .ena(wram_ena),
    .wea(wea),
    .addra(decoded_addr),
    .dina(dina),
    .douta(wram_out)
);

endmodule
