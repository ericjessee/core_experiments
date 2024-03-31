module avr_module #(SERIAL_BASE_ADDR = 16'hfea0) (
    input         clk,
    input         cclk,
    input         rst,
    input  [7:0]  din,
    output [7:0]  dout,
    input  [15:0] addr, 
    input         wr,
    input         rd,
    input         avr_tx, // AVR Tx => FPGA Rx
    output        avr_rx, // AVR Rx => FPGA Tx
    input         avr_rx_busy // AVR Rx buffer full
);

reg [7:0] tx_data;
wire new_tx_data;
wire tx_busy;
wire [7:0] rx_data;
reg new_rx_data;
wire avr_new_rx_data;
wire avr_ready;

avr_interface avr_interface (
    .clk(clk),
    .rst(rst),
    .cclk(cclk),
    .spi_miso(),
    .spi_mosi(),
    .spi_sck(),
    .spi_ss(),
    .spi_channel(),
    .tx(avr_rx), // FPGA tx goes to AVR rx
    .rx(avr_tx),
    .channel(), // invalid channel disables the ADC
    .new_sample(),
    .sample(),
    .sample_channel(),
    .tx_data(tx_data),
    .new_tx_data(new_tx_data),
    .tx_busy(tx_busy),
    .tx_block(avr_rx_busy),
    .rx_data(rx_data),
    .new_rx_data(avr_new_rx_data),
    .ready(avr_ready)
);

localparam SERIAL_STAT_ADDR    = SERIAL_BASE_ADDR;
localparam SERIAL_CTL_ADDR     = SERIAL_BASE_ADDR + 16'h1;
localparam SERIAL_TXDAT_ADDR   = SERIAL_BASE_ADDR + 16'h2;
localparam SERIAL_RXDAT_ADDR   = SERIAL_BASE_ADDR + 16'h3;

//I believe the actual flops are inside the avr interface
wire   stat_reg_ena;
assign stat_reg_ena = (addr == SERIAL_STAT_ADDR);

wire [7:0] stat_reg_bits;
assign stat_reg_bits[0]   = tx_busy;
assign stat_reg_bits[1]   = avr_rx_busy;
assign stat_reg_bits[2]   = new_rx_data;
assign stat_reg_bits[3]   = avr_ready;
assign stat_reg_bits[4]   = 1'b0; //unused
assign stat_reg_bits[5]   = 1'b0; //unused
assign stat_reg_bits[6]   = 1'b0; //unused
assign stat_reg_bits[7]   = 1'b0; //unused

wire   ctl_reg_ena;
assign ctl_reg_ena = (addr == SERIAL_CTL_ADDR);

reg [7:0] ctl_reg_bits;
assign new_tx_data     = ctl_reg_bits[0];
assign clr_new_rx_data = ctl_reg_bits[1]; 

wire tx_dat_ena; //write only
assign tx_dat_ena = (addr == SERIAL_TXDAT_ADDR);

wire rx_dat_ena; //clear on read?
assign rx_dat_ena = (addr == SERIAL_RXDAT_ADDR);

//bus output arbitration
assign dout      = (stat_reg_ena & rd) ? stat_reg_bits : 8'hz;
assign dout      = (rx_dat_ena   & rd) ? rx_data       : 8'hz; 
 
//bus input arbitration
//assign ctl_reg_bits = (ctl_reg_ena & wr) ? din : 8'hz;

//tx_data needs to be flopped in when the register is written to
always @(posedge clk) begin
    if (rst) begin
        ctl_reg_bits <= 8'b0;
        tx_data <= 8'h0;
        new_rx_data <= 1'b0;
    end else if (wr) begin
        if (ctl_reg_ena) begin
            ctl_reg_bits <= din;
        end else if (tx_dat_ena) begin
            tx_data <= din;
        end
    end else if (avr_new_rx_data) begin
        new_rx_data <= 1'b1;
    end else if (clr_new_rx_data) begin
        new_rx_data <= 1'b0;
    end else begin
        ctl_reg_bits[0] <= 8'b0; //don't want ctl reg bits to persist for more than a clock
    end
end

endmodule
