
module ram32(
             input                  clk,
             input                  resetn,
             input [ADDR_WIDTH-1:2] addr,
             input [31:0]           din,
             input [3:0]            bwe,
             output reg [31:0]      dout,
             input                  ren);
   
   // 12 = 4K words
   parameter ADDR_WIDTH = 12;
   
   reg [7:0]                        mem0[0:(1 << ADDR_WIDTH) - 1];
   reg [7:0]                        mem1[0:(1 << ADDR_WIDTH) - 1];
   reg [7:0]                        mem2[0:(1 << ADDR_WIDTH) - 1];
   reg [7:0]                        mem3[0:(1 << ADDR_WIDTH) - 1];
   
   always @(posedge clk) begin
      if (bwe[0])
        mem0[addr] <= din[7:0];

      if (bwe[1])
        mem1[addr] <= din[15:8];

      if (bwe[2])
        mem2[addr] <= din[23:16];

      if (bwe[3])
        mem3[addr] <= din[31:24];
   end
   
   always @(posedge clk) begin
      if (!resetn)
        dout <= 0;
      else if (ren)
        dout <= {mem3[addr], mem2[addr], mem1[addr], mem0[addr]};
   end
   
endmodule             

module rom32(
             input                    clk,
             input                    resetn,
             input [ADDR_WIDTH - 1:2] addr,
             input                    ren,
             output reg [31:0]        dout);
   
   reg [31:0]                         data [0:(1 << (ADDR_WIDTH - 2)) - 1];
   
   parameter ADDR_WIDTH = 12;
   parameter PATH = "example.hex";
   
   initial
     $readmemh(PATH, data);
   
   always @(posedge clk) begin
      if (!resetn)
        dout <= 0;
      else if (ren)
        dout <= data[addr];
   end
   
endmodule

// FIXME shifts
// FIXME tests
// FIXME EBREAK, SYSTEM
module barrel(
              input clk,
              input resetn,
              output reg halt);
   
   reg [31:0]       regs [0:31];
   reg [31:0] 	    pc;

   reg [31:2]       ram_addr;
   reg [31:0]       ram_din;
   reg [3:0]        ram_bwe;
   wire [31:0]      ram_dout;
   reg              ram_ren;
   ram32 ram(
             .clk(clk),
             .resetn(resetn),
             .addr(ram_addr),
             .din(ram_din),
             .bwe(ram_bwe),
             .dout(ram_dout),
             .ren(ram_ren));
   
   reg [31:2]       rom_addr; // word address
   reg              rom_ren;
   wire [31:0]      rom_dout;
   rom32 #(
           .PATH("example.hex")
           ) rom32 (
                    .clk(clk),
                    .resetn(resetn),
                    .addr(rom_addr),
                    .ren(rom_ren),
                    .dout(rom_dout));
   
   // states
   localparam FETCH = 8'b00000001;
   localparam DECODE = 8'b00000010;
   localparam READ = 8'b00000100;
   localparam EXECUTE = 8'b00001000;
   localparam WRITEBACK = 8'b00010000;
   
   reg [7:0]        state;
   
   initial
     $monitor("clk %b resetn %b state %08b instr %08x ram_bwe %04b ram_din %08x ram_ren %b ram_dout %08x", clk, resetn, state, instr, ram_bwe, ram_din, ram_ren, ram_dout);
   
   always @* begin
      case (state)
        FETCH: begin
           rom_ren = 1;
           rom_addr = pc[31:2];
        end
        
        default: begin
           rom_ren = 0;
           rom_addr = pc[31:2];
        end
      endcase
   end
   
   wire [31:0] instr = rom_dout;
   
   // opcodes
   localparam LUI = 7'b0110111;
   localparam AUIPC = 7'b0110111;
   localparam OP = 7'b0110011;
   localparam OP_IMM = 7'b0010011;
   localparam JAL = 7'b1101111;
   localparam JALR = 7'b1100111;
   localparam BRANCH = 7'b1100011;
   localparam LOAD = 7'b0000011;
   localparam STORE = 7'b0100011;
   localparam MEM_MISC = 7'b0001111;
   localparam SYSTEM = 7'b1110011;
   
   localparam CUSTOM0 = 7'b0001011;
   localparam CUSTOM1 = 7'b0101011;
   
   wire [6:0]       opcode;
   wire [4:0]       rs1, rs2, rd;
   wire [2:0]       funct3;
   wire [6:0]       funct7;
   wire [9:0]       funct;
   wire [11:0]      i_type_imm;
   wire [11:0]      s_type_imm;
   wire [12:1]      sb_type_imm;
   wire [31:12]     u_type_imm;
   wire [20:1]      uj_type_imm;
   
   assign opcode = instr[6:0];
   assign rd = instr[11:7];
   assign funct3 = instr[14:12];
   assign rs1 = instr[19:15];
   assign rs2 = instr[24:20];
   assign funct7 = instr[31:25];
   assign funct = {funct7, funct3};
   
   assign i_type_imm = instr[31:20];
   assign s_type_imm = {instr[31:25], instr[11:7]};
   assign sb_type_imm = {instr[31], instr[7], instr[30:25], instr[11:8]};
   assign u_type_imm = instr[31:12];
   assign uj_type_imm = {instr[31], instr[19:12], instr[20], instr[30:21]};
   
   localparam OP_ADD = 0;
   localparam OP_SUB = 1;
   localparam OP_EQ = 2;
   localparam OP_LT = 3;
   localparam OP_LTU = 4;
   localparam OP_GE = 5;
   localparam OP_GEU = 6;
   localparam OP_AND = 7;
   localparam OP_OR = 8;
   localparam OP_XOR = 9;
   localparam OP_SLL = 10;
   localparam OP_SRL = 11;
   localparam OP_SRA = 12;
   
   localparam [2:0] FUNCT3_ADDI = 3'b000;
   localparam [2:0] FUNCT3_SLTI = 3'b010;
   localparam [2:0] FUNCT3_SLTIU = 3'b011;
   localparam [2:0] FUNCT3_XORI = 3'b100;
   localparam [2:0] FUNCT3_ORI = 3'b110;
   localparam [2:0] FUNCT3_ANDI = 3'b111;
   localparam [2:0] FUNCT3_SLLI = 3'b001;
   localparam [2:0] FUNCT3_SRLI = 3'b101;
   localparam [2:0] FUNCT3_SRAI = 3'b101;

   localparam [2:0] FUNCT3_BEQ = 3'b000;
   localparam [2:0] FUNCT3_BNE = 3'b001;
   localparam [2:0] FUNCT3_BLT = 3'b100;
   localparam [2:0] FUNCT3_BGE = 3'b101;
   localparam [2:0] FUNCT3_BLTU = 3'b110;
   localparam [2:0] FUNCT3_BGEU = 3'b111;
   
   localparam [2:0] FUNCT3_ADD = 3'b000;
   localparam [2:0] FUNCT3_SUB = 3'b000;
   localparam [2:0] FUNCT3_SLL = 3'b001;
   localparam [2:0] FUNCT3_SLT = 3'b010;
   localparam [2:0] FUNCT3_SLTU = 3'b011;
   localparam [2:0] FUNCT3_XOR = 3'b100;
   localparam [2:0] FUNCT3_SRL = 3'b101;
   localparam [2:0] FUNCT3_SRA = 3'b101;
   localparam [2:0] FUNCT3_OR = 3'b110;
   localparam [2:0] FUNCT3_AND = 3'b111;
   
   localparam [2:0] FUNCT3_SB = 3'b000;
   localparam [2:0] FUNCT3_SH = 3'b001;
   localparam [2:0] FUNCT3_SW = 3'b010;
   
   localparam [2:0] FUNCT3_LB = 3'b000;
   localparam [2:0] FUNCT3_LH = 3'b001;
   localparam [2:0] FUNCT3_LW = 3'b010;
   localparam [2:0] FUNCT3_LBU = 3'b100;
   localparam [2:0] FUNCT3_LHU = 3'b101;
   
   localparam [1:0] WIDTH_BYTE = 2'b00;
   localparam [1:0] WIDTH_HALF = 2'b01;
   localparam [1:0] WIDTH_WORD = 2'b10;
   
   // custom
   localparam [2:0] FUNCT3_DISPLAY = 3'b000;
   localparam [2:0] FUNCT3_HALT = 3'b001;
   
   localparam [6:0] FUNCT7_ADD = 7'b0000000;
   localparam [6:0] FUNCT7_SUB = 7'b0100000;
   localparam [6:0] FUNCT7_SLL = 7'b0000000;
   localparam [6:0] FUNCT7_SLT = 7'b0000000;
   localparam [6:0] FUNCT7_SLTU = 7'b0000000;
   localparam [6:0] FUNCT7_AND = 7'b0000000;
   localparam [6:0] FUNCT7_OR = 7'b0000000;
   localparam [6:0] FUNCT7_XOR = 7'b0000000;
   localparam [6:0] FUNCT7_SRL = 7'b0000000;
   localparam [6:0] FUNCT7_SRA = 7'b0100000;
   
   localparam [9:0] FUNCT_ADD = {FUNCT7_ADD, FUNCT3_ADD};
   localparam [9:0] FUNCT_SUB = {FUNCT7_SUB, FUNCT3_SUB};
   localparam [9:0] FUNCT_SLL = {FUNCT7_SLL, FUNCT3_SLL};
   localparam [9:0] FUNCT_SLT = {FUNCT7_SLT, FUNCT3_SLT};
   localparam [9:0] FUNCT_SLTU = {FUNCT7_SLTU, FUNCT3_SLTU};
   localparam [9:0] FUNCT_AND = {FUNCT7_AND, FUNCT3_AND};
   localparam [9:0] FUNCT_OR = {FUNCT7_OR, FUNCT3_OR};
   localparam [9:0] FUNCT_XOR = {FUNCT7_XOR, FUNCT3_XOR};
   localparam [9:0] FUNCT_SRL = {FUNCT7_SRL, FUNCT3_SRL};
   localparam [9:0] FUNCT_SRA = {FUNCT7_SRA, FUNCT3_SRA};
   
   reg [3:0]        op;
   reg [31:0]       op1, op2;
   reg [31:0]       result;

   reg [31:0]       eaddr;
   
   always @* begin : load_store
      if (opcode == LOAD)
        eaddr = op1 + {{20{i_type_imm[11]}}, i_type_imm};
      else
        eaddr = op1 + {{20{s_type_imm[11]}}, s_type_imm}; // store
      
      ram_addr = eaddr[31:2];
      
      if (state == EXECUTE && opcode == LOAD)
        ram_ren = 1;
      else
        ram_ren = 0;
      
      if (state == EXECUTE && opcode == STORE) begin
         case (funct3)
           FUNCT3_SW: begin
              ram_bwe = 4'b1111;
              ram_din = op2;
           end
           
           FUNCT3_SH: begin
              case (eaddr[1])
                1'b0: ram_bwe = 4'b0011;
                1'b1: ram_bwe = 4'b1100;
              endcase
              ram_din = {2{op2[15:0]}};
           end
           
           FUNCT3_SB: begin
              case (eaddr[1:0])
                2'b00: ram_bwe = 4'b0001;
                2'b01: ram_bwe = 4'b0010;
                2'b10: ram_bwe = 4'b0100;
                2'b11: ram_bwe = 4'b1000;
              endcase
              ram_din = {4{op2[7:0]}};
           end
           
           default: begin
              ram_bwe = 0;
              ram_din = op2;
           end
         endcase
      end else begin
         ram_bwe = 0;
         ram_din = op2;
      end
   end
   
   reg [31:0]       pc4;
   reg [31:0]       pc_result;
   
   // jal: pc <= pc + $signed(uj_imm << 1), rd <= pc + 4
   // jalr: pc <= (rs1 + $signed(i_imm)) & ~1, rd <= pc + 4
   // b: if (cond) pc <= pc + $signed(b_imm << 1)
   always @(posedge clk) begin
      if (!resetn)
        pc <= 0;
      else begin
         case (state)
           EXECUTE:
             pc4 <= pc + 4;
           
           WRITEBACK: begin : pc_writeback
              case (opcode)
                JAL:   pc <= pc + {{12{uj_type_imm[20]}}, uj_type_imm, 1'b0};
                JALR:  begin : pc_writeback_jalr
                   reg [31:0] pc_result;
                   pc_result = op1 + {{20{i_type_imm[11]}}, i_type_imm};
                   pc <= {pc_result[31:1], 1'b0};
                end
                
                BRANCH: begin
                   if (result[0])
                     pc <= pc + {{19{sb_type_imm[12]}}, sb_type_imm, 1'b0};
                   else
                     pc <= pc4;
                end
                
                default:
                  pc <= pc4;
              endcase
           end
         endcase
      end
   end
   
   always @(posedge clk) begin
      if (!resetn) begin
         pc <= 0;
         state <= FETCH;
         halt <= 0;
      end else begin
         case (state)
           FETCH:
             state <= DECODE;
           
           DECODE: begin
	      // $display("DECODE: %08x", instr);
	      // $display("opcode %07b funct3 %03b", opcode, funct3);
              if (opcode == CUSTOM0 && funct3 == FUNCT3_HALT)
                halt <= 1;
              
              case (opcode)
                AUIPC: op <= OP_ADD;
                OP:
                  case (funct)
                    FUNCT_ADD: op <= OP_ADD;
                    FUNCT_SUB: op <= OP_SUB;
                    FUNCT_SLT: op <= OP_LT;
                    FUNCT_SLTU: op <= OP_LTU;
                    FUNCT_AND: op <= OP_AND;
                    FUNCT_OR: op <= OP_OR;
                    FUNCT_XOR: op <= OP_XOR;
		    FUNCT_SLL: op <= OP_SLL;
		    FUNCT_SRL: op <= OP_SRL;
		    FUNCT_SRA: op <= OP_SRA;
                  endcase
                OP_IMM:
                  case (funct3)
                    FUNCT3_ADDI: op <= OP_ADD;
                    FUNCT3_SLTI: op <= OP_LT;
                    FUNCT3_SLTIU: op <= OP_LTU;
                    FUNCT3_ANDI: op <= OP_AND;
                    FUNCT3_ORI: op <= OP_OR;
                    FUNCT3_XORI: op <= OP_XOR;
		    FUNCT3_SLLI: op <= OP_SLL;
		    FUNCT3_SRLI: op <= OP_SRL;
		    FUNCT3_SRAI: op <= OP_SRA;
                  endcase
                BRANCH:
                  case (funct3)
                    FUNCT3_BEQ: op <= OP_EQ;
                    FUNCT3_BNE: op <= OP_EQ;
                    FUNCT3_BLT: op <= OP_LT;
                    FUNCT3_BLTU: op <= OP_LTU;
                    FUNCT3_BGE: op <= OP_GE;
                    FUNCT3_BGEU: op <= OP_GEU;
                  endcase
              endcase
              
              state <= READ;
           end
           
           READ: begin
              if (opcode == AUIPC)
                op1 <= pc;
              else if (rs1 == 0)
                op1 <= 0;
              else
                op1 <= regs[rs1];
              
              if (opcode == OP_IMM)
                op2 <= {{20{i_type_imm[11]}}, i_type_imm};
              else if (opcode == AUIPC)
                op2 <= {u_type_imm, 12'b0};
              else if (rs2 == 0)
                op2 <= 0;
              else
                op2 <= regs[rs2];
              
              state <= EXECUTE;
           end
           
           EXECUTE: begin
              if (opcode == CUSTOM0 && funct3 == FUNCT3_DISPLAY)
                $display("x%0d: %x", rs1, op1);
              
              case (op)
                OP_ADD: result <= op1 + op2;
                OP_SUB: result <= op1 - op2;
                OP_EQ: result <= op1 == op2;
                OP_LT: result <= $signed(op1) < $signed(op2);
                OP_LTU: result <= op1 < op2;
                OP_GE: result <= $signed(op1) >= $signed(op2);
                OP_GEU: result <= op1 >= op2;
                OP_AND: result <= op1 & op2;
                OP_OR: result <= op1 | op2;
                OP_XOR: result <= op1 ^ op2;
		OP_SLL:
		  if (op2[4:0] == 0)
		    result <= op1;
		  else if (op2[4:0] == 1)
		    result <= {op1[30:0], 1'b0};
		  else begin
		     op1 <= {op1[30:0], 1'b0};
		     op2[4:0] <= op2[4:0] - 1;
		  end
		
		OP_SRL:
		  if (op2[4:0] == 0)
		    result <= op1;
		  else if (op2[4:0] == 1)
		    result <= {1'b0, op1[31:1]};
		  else begin
		     op1 <= {1'b0, op1[31:1]};
		     op2[4:0] <= op2[4:0] - 1;
		  end
		
		OP_SRA:
		  if (op2[4:0] == 0)
		    result <= op1;
		  else if (op2[4:0] == 1)
		    result <= {op1[31], op1[31:1]};
		  else begin
		     op1 <= {op1[31], op1[31:1]};
		     op2[4:0] <= op2[4:0] - 1;
		  end
              endcase
	      
	      if ((op != OP_SLL && op != OP_SRL && op != OP_SRA)
		  || op2[4:0] == 0 || op2[4:0] == 1)
		state <= WRITEBACK;
           end
           
           WRITEBACK: begin
              if (opcode == LUI) begin
		 // $display("regs[%d] <= %08x", rd, {u_type_imm, 12'b0});
		 regs[rd] <= {u_type_imm, 12'b0};
	      end else if (opcode == AUIPC || opcode == OP || opcode == OP_IMM) begin
		 // $display("regs[%d] <= %08x", rd, result);
                 regs[rd] <= result;
              end else if (opcode == JAL || opcode == JALR) begin
		 // $display("regs[%d] <= %08x", rd, pc + 4);
                 regs[rd] <= pc4;
	      end else if (opcode == LOAD) begin : writeback_load
                 reg [31:0] v;
                 
                 case (funct3)
                   FUNCT3_LW: v = ram_dout;
                   
                   FUNCT3_LH: begin
                     case (eaddr[1])
                       1'b0: v = {{16{ram_dout[15]}}, ram_dout[15:0]};
                       1'b1: v = {{16{ram_dout[31]}}, ram_dout[31:16]};
                     endcase
                   end

                   FUNCT3_LHU: begin
                     case (eaddr[1])
                       1'b0: v = {16'b0, ram_dout[15:0]};
                       1'b1: v = {16'b0, ram_dout[31:16]};
                     endcase
                   end
                   
                   FUNCT3_LB: begin
                      case (eaddr[1:0])
                        2'b00: v = {{24{ram_dout[7]}}, ram_dout[7:0]};
                        2'b01: v = {{24{ram_dout[15]}}, ram_dout[15:8]};
                        2'b10: v = {{24{ram_dout[23]}}, ram_dout[23:16]};
                        2'b11: v = {{24{ram_dout[31]}}, ram_dout[31:24]};
                      endcase
                   end
                   
                   FUNCT3_LBU: begin
                     case (eaddr[1:0])
                       2'b00: v = {24'b0, ram_dout[7:0]};
                       2'b01: v = {24'b0, ram_dout[15:8]};
                       2'b10: v = {24'b0, ram_dout[23:16]};
                       2'b11: v = {24'b0, ram_dout[31:24]};
                     endcase
                   end
                 endcase
                 
                 regs[rd] <= v;
              end
	      
              state <= FETCH;
           end
           
         endcase
      end
        
        
   end
   
endmodule
