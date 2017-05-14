
// FIXME todo shifts, load, store
// FIXME display register instruction (custom)
module barrel(
              input clk,
              input resetn,
              output reg halt);
   
   reg [31:0]       regs [0:31];
   reg              pc;
   
   reg [31:0]       rom [0:1023];
   
   initial
     $readmemh("image.hex", rom);
   
   reg [31:0]       instr;
   reg [31:0]       result;
   
   // states
   localparam fetch = 8'b00000001;
   localparam decode = 8'b00000010;
   localparam read = 8'b00000100;
   localparam execute = 8'b00001000;
   localparam writeback = 8'b00010000;
   
   reg [7:0]        state;

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
   
   wire [7:0]       opcode;
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
   
   reg [3:0]          op;
   reg [31:0]         op1, op2;
   reg [31:0]         pc_op2;
   
   always @(posedge clk) begin
      if (!resetn) begin
         pc <= 0;
         state <= fetch;
         halt <= 0;
      end else begin
         case (state)
           fetch: begin
              instr <= rom[pc];
              state <= decode;
           end
           
           decode: begin
              if (opcode == CUSTOM0 && funct3 == FUNCT3_HALT)
                halt <= 1;
              
              case (opcode)
                LUI: op <= OP_ADD;
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
                  endcase
                OP_IMM:
                  case (funct3)
                    FUNCT3_ADDI: op <= OP_ADD;
                    FUNCT3_SLTI: op <= OP_LT;
                    FUNCT3_SLTIU: op <= OP_LTU;
                    FUNCT3_ANDI: op <= OP_AND;
                    FUNCT3_ORI: op <= OP_OR;
                    FUNCT3_XORI: op <= OP_XOR;
                  endcase
                JALR: op <= OP_ADD;
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
                  
              state <= read;
           end
           
           read: begin
              if (opcode == CUSTOM0 && funct3 == FUNCT3_DISPLAY)
                $display("x%d: %x", rs1, regs[rs1]);
              
              if (opcode == AUIPC || opcode == JALR)
                op1 <= pc;
              else if (rs1 == 0)
                op1 <= 0;
              else
                op1 <= regs[rs1];
              
              if (opcode == OP_IMM || opcode == JALR)
                op2 <= {{20{i_type_imm[11]}}, i_type_imm};
              else if (opcode == AUIPC || opcode == LUI)
                op2 <= {u_type_imm, 12'b0};
              else if (rs2 == 0)
                op2 <= 0;
              else
                op2 <= regs[rs2];
              
              // set pc_op2
              if (opcode == JAL)
                pc_op2 <= {12'b0, uj_type_imm, 1'b0};
              else if (opcode == BRANCH)
                pc_op2 <= {19'b0, sb_type_imm, 1'b0};
              
              state <= execute;
           end
           
           execute: begin
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
              endcase
              
              state <= writeback;
           end
           
           writeback: begin
              if (opcode == LUI || opcode == AUIPC || opcode == OP || opcode == OP_IMM || opcode == STORE)
                regs[rd] <= result;
              else if (opcode == JAL || opcode == JALR)
                regs[rd] <= pc + 4;
              
              if (opcode == JAL || opcode == BRANCH)
                pc <= pc + pc_op2;
              else if (opcode == JALR)
                pc <= {result[31:1], 1'b0};
              else
                pc <= pc + 4;
              
              state <= fetch;
           end
           
         endcase
      end
        
        
   end
   
endmodule
