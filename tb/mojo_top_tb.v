module mojo_top_tb ();

reg  clk;
reg  cclk;
reg  rst_n;
wire [7:0] led;
wire [7:0] avr_rx;
reg  [7:0] avr_tx;
reg avr_rx_busy;

mojo_top mojo_top(
    .clk(clk),
    .cclk(cclk),
    .rst_n(rst_n),
    .led(led),
    .avr_rx(avr_rx),
    .avr_tx(avr_tx),
    .avr_rx_busy(avr_rx_busy)
);

//20ns == 50MHz 
always #20 clk = ~clk;

initial begin
    clk <= 0;
    cclk <= 1;
    avr_rx_busy <= 0;
    rst_n <= 0;
    #20
    rst_n <= 1;
    #1000000000
    rst_n <= 1;
end

endmodule
