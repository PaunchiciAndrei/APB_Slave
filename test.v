module top_apb();

    //initial values for clock and reset   
    reg         clk   =0;
    reg         rst_n =1;
    
    //APB signals
    reg         psel    ; //generated by master
    reg         penable ; //generated by master
    reg         pwrite  ; //generated by master 
    reg  [ 2:0] paddr   ; //generated by master
    reg  [31:0] pwdata  ; //generated by master
    
    wire        pready  ; //just connection to dut
    wire        pslverr ; //just connection to dut
    wire [31:0] prdata  ; //just connection to dut
    
    //registers written on APB interface and outputs from dut
    wire [31:0] reg0    ; //just connection to dut
    wire [15:0] reg1    ; //just connection to dut
    wire [ 7:0] reg2    ; //just connection to dut
    wire [ 3:0] reg3    ; //just connection to dut
    wire [ 2:0] reg4    ; //just connection to dut
    wire [ 6:0] reg5    ; //just connection to dut
    wire [22:0] reg6    ; //just connection to dut
    
    //generate reset
    initial
    begin
     #4    rst_n = 0;
     #20   rst_n = 1;
     #3200 
     $finish();
     end
     
    //generate clock 
    always  #2 clk<=!clk;
    
    //code for wavefor generation in EDA playground  
    initial
    begin
      $dumpfile("dump.vcd"); 
      $dumpvars(0);
    end
    
    reg   [2:0] op_cnt;
    reg         psel_d;
    reg         pready_d;
    wire        pos_pready;
    wire        pos_psel;
    reg  [31:0] rand_no;
    wire        start_apb_op;
    
    
    assign start_apb_op = pready & (op_cnt[2:0] == rand_no[2:0]);
    
    //delay pready for posedge detection
    always @ (posedge clk or negedge rst_n)
    if (!rst_n)   rand_no <= $random; else 
    if (pos_psel) rand_no <= $random;
     
    //delay pready for posedge detection
    always @ (posedge clk or negedge rst_n)
    if (!rst_n) pready_d <= 1'b0; else 
                pready_d <= pready;
      
    //detect pready posedge
    assign pos_pready = pready & !pready_d;
    
    //counter for operation generation; 
    always @ (posedge clk or negedge rst_n)
    if (!rst_n)     op_cnt <= 3'b0; else 
    if (pos_pready) op_cnt <= 3'b0; else  // reset counter at the end of operation
    if (~psel)      op_cnt <= op_cnt + 1; //do not counter if operation in progress
     
    //set psel once the counter reaches a rand value; keep it '1' until the end of operation (ready set to '1')
    always @ (posedge clk or negedge rst_n)
    if (!rst_n)       psel <= 1'b0;else 
    if (pos_pready)   psel <= 1'b0;else 
    if (start_apb_op) psel <= 1'b1;
     
    //delay psel for penable generation
    always @ (posedge clk or negedge rst_n)
    if (!rst_n)      psel_d <= 1'b0;else 
    if (pos_pready)  psel_d <= 1'b0;else 
      psel_d <= psel;
    //posedge of psel
    assign pos_psel = psel & psel_d;
    
    //generate penable 	
    always @ (posedge clk or negedge rst_n)
    if (!rst_n)        penable <= 1'b1; else  
    if (~penable)      penable <= 1'b1; else //penable needs to be low 1 cycle
    if (start_apb_op)  penable <= 1'b0;      // drop penable when psel is asserted
      
    
    always @ (posedge clk or negedge rst_n) 
    if (!rst_n)                                 pwrite <= 1'd0; else
    if(start_apb_op) pwrite <= rand_no[0];
      
    always @ (posedge clk or negedge rst_n) 
    if (!rst_n)                                 paddr <= 3'd0; else
    if(start_apb_op) paddr <= rand_no[31:29];
     
    always @ (posedge clk or negedge rst_n) 
    if (!rst_n)                                 pwdata <= 32'd0; else
    if(start_apb_op) pwdata <= rand_no[31:0];
      
    apb_slave  test (
        .clk    (clk    ),
        .rst_n  (rst_n  ),
        .PSEL   (psel   ),
        .PENABLE(penable),
        .PWRITE (pwrite ),
      .PADDR  (paddr),
        .PWDATA (pwdata ),
        .PREADY (pready ),
        .PRDATA (prdata ),
        .PSLVERR(pslverr),
      .n0     (reg0), 
      .n1     (reg1),  
      .n2     (reg2),  
      .n3     (reg3),  
      .n4     (reg4),  
      .n5     (reg5),  
      .n6     (reg6)
     );
    
    
    endmodule