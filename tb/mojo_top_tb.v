module mojo_top_tb ();

reg clk;
reg rst_n;
wire [7:0] led;

mojo_top mojo_top(
    .clk(clk),
    .rst_n(rst_n),
    .led(led)
);

//20ns == 50MHz 
always #20 clk = ~clk;

initial begin
    clk <= 0;
    rst_n <= 0;
    #20
    rst_n <= 1;
    #1000000000
    rst_n <= 1;
end

endmodule
