/***********************************************************************
 * A SystemVerilog testbench for an instruction register.
 * The course labs will convert this to an object-oriented testbench
 * with constrained random test generation, functional coverage, and
 * a scoreboard for self-verification.
 **********************************************************************/

module instr_register_test
  import instr_register_pkg::*;  // user-defined types are defined in instr_register_pkg.sv
  (input  logic          clk,
   output logic          load_en,
   output logic          reset_n,
   output operand_t      operand_a,
   output operand_t      operand_b,
   output opcode_t       opcode,
   output address_t      write_pointer,
   output address_t      read_pointer,
   input  instruction_t  instruction_word
  );

  timeunit 1ns/1ns;
  
  parameter WR_NR = 3;
  parameter RD_NR = 2; // ( WR_NR - 1 ) deoarece for-ul va porni de la valoarea 0
  parameter read_order = 2; // 0 - incremental; 1 - random; 2 - decremental;
  parameter write_order = 2; // 0 - incremental; 1 - random; 2 - decremental;
  parameter seed_val = 801046;
  instruction_t  iw_reg_test [0:31];
  int error_number = 0;
  int seed = seed_val;
  parameter TEST_NAME = "test";

  initial begin
    $display("\n\n***********************************************************");
    $display(    "***         THIS IS A SELF-CHECKING TESTBENCH.          ***");
    $display(    "***********************************************************");

    $display("\nReseting the instruction register...");
    write_pointer  = 5'h00;         // initialize write pointer
    read_pointer   = 5'h1F;         // initialize read pointer
    load_en        = 1'b0;          // initialize load control line
    reset_n       <= 1'b0;          // assert reset_n (active low)
    reset_signal();
    repeat (2) @(posedge clk) ;     // hold in reset for 2 clock cycles
    reset_n        = 1'b1;          // deassert reset_n (active low)

    $display("\nWriting values to register stack...");
    @(posedge clk) load_en = 1'b1;  // enable writing to register
    // repeat (3) begin - A.S.
    repeat (WR_NR) begin
      @(posedge clk) randomize_transaction;
      @(negedge clk) print_transaction;
    end
    @(posedge clk) load_en = 1'b0;  // turn-off writing to register

              // Tema L4: De adaugat o variabila globala care verifica numarul erorilor (0 erori = test passed)
    // read back and display same three register locations
    $display("\nReading back the same register locations written...");
    if (read_order == 0) begin // - incremental
      for (int i=0; i<=RD_NR; i++) begin
        // later labs will replace this loop with iterating through a
        // scoreboard to determine which addresses were written and
        // the expected values to be read back
        @(posedge clk) read_pointer = i%32;
        @(negedge clk) print_results;
        check_result();
      end
    end

    if (read_order == 1) begin // - random
      for (int i=0; i<=RD_NR; i++) begin
        @(posedge clk) read_pointer = $random%32;
        @(negedge clk) print_results;
        check_result();
      end
    end

    if (read_order == 2) begin // - decremental
      for (int i=0; i<=RD_NR; i++) begin
        @(posedge clk) read_pointer = 31-(i%32);
        @(negedge clk) print_results;
        check_result();
      end
    end

    @(posedge clk) ;
    $display("\n\n***********************************************************");
    $display(    "***         THIS IS A SELF-CHECKING TESTBENCH.          ***");
    $display(    "***********************************************************");
    final_report();
    write_regression_status();
    $finish;
  end

  function void randomize_transaction; // daca vrem sa nu fie o ordine incrementala folosim: write_pointer = $unsigned($random)%32; pt. random
    // A later lab will replace this function with SystemVerilog
    // constrained random values
    //
    // The stactic temp variable is required in order to write to fixed
    // addresses of 0, 1 and 2.  This will be replaceed with randomizeed
    // write_pointer values in a later lab
    //
    if(write_order == 0) begin
    static int temp = 0;
      operand_a     = $random(seed)%16;                 // between -15 and 15
      operand_b     = $unsigned($random)%16;            // between 0 and 15
      opcode        = opcode_t'($unsigned($random)%9);  // between 0 and 7, cast to opcode_t type
      write_pointer = temp++; // - incremental
    end

    if(write_order == 1) begin
      operand_a     = $random(seed)%16;                 // between -15 and 15
      operand_b     = $unsigned($random)%16;            // between 0 and 15
      opcode        = opcode_t'($unsigned($random)%9);  // between 0 and 7, cast to opcode_t type
      write_pointer = $unsigned($random)%32; // - random
    end

    if(write_order == 2) begin
    static int temp = 31;
      operand_a     = $random(seed)%16;                 // between -15 and 15
      operand_b     = $unsigned($random)%16;            // between 0 and 15
      opcode        = opcode_t'($unsigned($random)%9);  // between 0 and 7, cast to opcode_t type
      write_pointer = temp--; // - decremental
    end
    
    $display(" Test: operand_a = %0d, operand_b = %0d, opcode = %0d at time %0t",   operand_a, operand_b, opcode, $time);
    iw_reg_test[write_pointer] = '{opcode, operand_a, operand_b, 64'b0}; // concatenam valorile in iw_reg_test
  endfunction: randomize_transaction
    

  function void print_transaction;
    $display("Writing to register location %0d: ", write_pointer);
    $display("  opcode = %0d (%s)", opcode, opcode.name);
    $display("  operand_a = %0d",   operand_a);
    $display("  operand_b = %0d\n", operand_b);
  endfunction: print_transaction

  function void print_results;
    $display("Read from register location %0d: ", read_pointer);
    $display("  opcode = %0d (%s)", instruction_word.opc, instruction_word.opc.name);
    $display("  operand_a = %0d",   instruction_word.op_a);
    $display("  operand_b = %0d", instruction_word.op_b);
    $display("  rezultat = %0d\n", instruction_word.rez);
  endfunction: print_results

  function void reset_signal;
    foreach (iw_reg_test[i]) begin
          iw_reg_test[i] = '{opc:ZERO,default:0}; // reset la zero
          //$display("Am resetat locatia %0d", i);
    end
  endfunction: reset_signal

  function void check_result;
    if(iw_reg_test[read_pointer].op_a === instruction_word.op_a)
      $display("Valoarea lui op_a este stocata corect\n");
    else begin
      $display("Valoarea lui op_a NU este stocata corect\n");
      error_number++;
    end
    
    if(iw_reg_test[read_pointer].op_b === instruction_word.op_b)
      $display("Valoarea lui op_b este stocata corect\n");
    else begin
      $display("Valoarea lui op_b NU este stocata corect\n");
      error_number++;
    end

    if(iw_reg_test[read_pointer].opc === instruction_word.opc)
      $display("Valoarea lui opc este stocata corect\n");
    else begin
      $display("Valoarea lui opc NU este stocata corect\n");
      error_number++;
    end
    
    case (iw_reg_test[read_pointer].opc)
    ZERO: iw_reg_test[read_pointer].rez = 0;
    PASSA: iw_reg_test[read_pointer].rez = iw_reg_test[read_pointer].op_a;
    PASSB: iw_reg_test[read_pointer].rez = iw_reg_test[read_pointer].op_b;
    ADD: iw_reg_test[read_pointer].rez = iw_reg_test[read_pointer].op_a + iw_reg_test[read_pointer].op_b;
    SUB: iw_reg_test[read_pointer].rez = iw_reg_test[read_pointer].op_a - iw_reg_test[read_pointer].op_b;
    MULT: iw_reg_test[read_pointer].rez = iw_reg_test[read_pointer].op_a * iw_reg_test[read_pointer].op_b;
    DIV: begin
      if(iw_reg_test[read_pointer].op_b === 0)
        iw_reg_test[read_pointer].rez = 0;
      else
        iw_reg_test[read_pointer].rez = iw_reg_test[read_pointer].op_a / iw_reg_test[read_pointer].op_b;
    end
    MOD: begin
      if(iw_reg_test[read_pointer].op_b ===0)
        iw_reg_test[read_pointer].rez = 0;
      else
        iw_reg_test[read_pointer].rez = iw_reg_test[read_pointer].op_a % iw_reg_test[read_pointer].op_b;
    end
    POW: begin
      if(iw_reg_test[read_pointer].op_a ===0)
        iw_reg_test[read_pointer].rez = 0;
      else
        iw_reg_test[read_pointer].rez = iw_reg_test[read_pointer].op_a ** iw_reg_test[read_pointer].op_b;
    end

    default: iw_reg_test[read_pointer].rez = 0;
    endcase
  if(iw_reg_test[read_pointer].rez === instruction_word.rez)
    $display("Test passed (rezultat corect)\n");
  else begin
    $display("Test failed (rezultat gresit)\n");
    error_number++;
  end
  endfunction: check_result

  function void final_report;
        $display("\n***************************************************");
        $display("***                  FINAL REPORT               ***");
        $display("***************************************************");
        $display("Total number of errors encountered: %0d", error_number);
        if (error_number == 0)
            $display("Congratulations! No errors found.");
        else
            $display("There were %0d errors detected.", error_number);
        $display("*\n");
  endfunction

  function void write_regression_status;
    int file;
    file = $fopen("../reports/regression_transcript/regression_status.txt", "a");
    if(error_number == 0) begin
      $fdisplay(file, "%s : passed", TEST_NAME);
    end
    else begin
      $fdisplay(file, "%s : failed",TEST_NAME);
    end
    $fclose(file);
  endfunction: write_regression_status


endmodule: instr_register_test
