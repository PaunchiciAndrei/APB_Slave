module apb_slave(
    input PSEL,
    input PENABLE,
    input PWRITE,
    input [2:0]PADDR,
    input reg [31:0]PWDATA,
    input rst_n,
    input clk,
    
    output reg PREADY,
    output reg [31:0]PRDATA,
    output reg PSLVERR,
    output reg [31:0] n0,
    output reg [15:0] n1,
    output reg [7:0] n2,
    output reg [3:0] n3,
    output reg [2:0] n4,
    output reg [6:0] n5,
    output reg [22:0] n6
  );
    wire sstart;
    assign sstart=(PSEL==1'b1 && PENABLE==1'b0);
  
    always @ (posedge clk or negedge rst_n) begin
      if(!rst_n)
        PREADY<=1'b1;
      else if (sstart)
        PREADY<=1'b0;
      else 
        PREADY<=1'b1;
    end
    
      always @ (posedge clk or negedge rst_n) begin
      if(!rst_n)
        PSLVERR<=1'b0;
        else if (PADDR>6 && PREADY==1'b0)
        PSLVERR<=1'b1;
        else
        PSLVERR<=1'b0;
    end
    
    always @ (posedge clk or negedge rst_n) begin
      if(!rst_n)
        PRDATA<=32'b0;
      else if(sstart && PWRITE==1'b0)
        case(PADDR)
  
        2'b0:PRDATA<= n0;
        2'b1:PRDATA<= n1;
        2'b10:PRDATA<= n2;
        2'b11:PRDATA<= n3;
        2'b100:PRDATA<= n4;
        2'b101:PRDATA<= n5;
        2'b110:PRDATA<= n6;
        default: PRDATA<=32'b0;
        endcase
      
    end
    
    always @ (posedge clk or negedge rst_n) begin
      if(!rst_n)
        n0<=32'b0;
      else if(PADDR==3'b0 && PWRITE==1'b1 && sstart)
        n0<=PWDATA;
    end
  
    always @ (posedge clk or negedge rst_n) begin
      if(!rst_n)
        n1<=16'b0;
      else if(PADDR==3'b1 && PWRITE==1'b1 && sstart)
        n1<=PWDATA[16:0];
    end
    
    always @ (posedge clk or negedge rst_n) begin
      if(!rst_n)
        n2<=8'b0;
      else if(PADDR==3'b10 && PWRITE==1'b1 && sstart)
        n2<=PWDATA[7:0];
    end
  
    always @ (posedge clk or negedge rst_n) begin
      if(!rst_n)
        n3<=4'b0;
      else if(PADDR==3'b11 && PWRITE==1'b1 && sstart)
        n3<=PWDATA[3:0];
    end
    
    always @ (posedge clk or negedge rst_n) begin
      if(!rst_n)
        n4<=3'b0;
      else if(PADDR==3'b100 && PWRITE==1'b1 && sstart)
        n4<=PWDATA[2:0];
    end
    
    always @ (posedge clk or negedge rst_n) begin
      if(!rst_n)
        n5<=7'b0;
      else if(PADDR==3'b101 && PWRITE==1'b1 && sstart)
        n5<=PWDATA[6:0];
    end
    
    always @ (posedge clk or negedge rst_n) begin
      if(!rst_n)
        n6<=23'b0;
      else if(PADDR==3'b110 && PWRITE==1'b1 && sstart)
        n6<=PWDATA[22:0];
    end
    
  endmodule
    