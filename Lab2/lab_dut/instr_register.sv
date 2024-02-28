/***********************************************************************
 * A SystemVerilog RTL model of an instruction regisgter
 *
 * An error can be injected into the design by invoking compilation with
 * the option:  +define+FORCE_LOAD_ERROR
 *
 **********************************************************************/

module instr_register
import instr_register_pkg::*;  // user-defined types are defined in instr_register_pkg.sv
(input  logic          clk,
 input  logic          load_en,
 input  logic          reset_n,
 input  operand_t      operand_a,
 input  operand_t      operand_b,
 input  opcode_t       opcode,
 input  address_t      write_pointer,
 input  address_t      read_pointer,
 output instruction_t  instruction_word // doar la semnale de output putem sa asignam valori
);
  timeunit 1ns/1ns;

  instruction_t  iw_reg [0:31];  // an array of instruction_word structures // un array de 32 de locatii de instruction_t, nu este vazut ca un nr. intreg

  // write to the register
  always@(posedge clk, negedge reset_n)   // write into register // pe front poz. de ceas si front neg. de reset - evaluam:
    if (!reset_n) begin // daca reset-ul (care e activ in 0) este 0, atunci:
      foreach (iw_reg[i]) // pentru fiecare element din array-ul nostru:
        iw_reg[i] = '{opc:ZERO,default:0};  // reset to all zeros // punem opcode-ul zero , default-> a si b o sa fie tot 0
    end
    else if (load_en) begin // daca load_en este 1 adica putem incarca date (deci cand avem un semnal):
      iw_reg[write_pointer] = '{opcode,operand_a,operand_b}; // esantionam a, b si opcode, adica punem in array de -> write_pointer[31:0](asta fiind adresa) 
    end

  // read from the register
  assign instruction_word = iw_reg[read_pointer];  // continuously read from register

// compile with +define+FORCE_LOAD_ERROR to inject a functional bug for verification to catch
`ifdef FORCE_LOAD_ERROR
initial begin
  force operand_b = operand_a; // cause wrong value to be loaded into operand_b
end
`endif

endmodule: instr_register
