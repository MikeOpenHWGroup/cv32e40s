// Copyright 2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

////////////////////////////////////////////////////////////////////////////////
//                                                                            //
// Author:         Matthias Baer - baermatt@student.ethz.ch                   //
//                 Andreas Traber - atraber@student.ethz.ch                   //
//                 Michael Gautschi - gautschi@iis.ee.ethz.ch                 //
//                 Halfdan Bechmann - halfdan.bechmann@silabs.com             //
//                                                                            //
// Description:    RTL assertions for the mult module                         //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

module cv32e40x_mult_sva
  import uvm_pkg::*;
  import cv32e40x_pkg::*;
  (
   input logic        clk,
   input logic        rst_n,
   input logic [31:0] op_a_i,
   input logic [31:0] op_b_i,
   input logic        ready_o,
   input logic        enable_i,
   input logic [31:0] result_o,
   input logic [ 1:0] short_signed_i,
   input              mul_opcode_e operator_i,
   input              mult_state_e mulh_state);

  // check multiplication result for mulh
  a_mulh_result :
    assert property (@(posedge clk)
                     ((mulh_state == AHBH) && (operator_i == MUL_H) && (short_signed_i == 2'b11))
                     |->
                     (result_o == (($signed({{32{op_a_i[31]}}, op_a_i}) * $signed({{32{op_b_i[31]}}, op_b_i})) >>> 32) ) )
      else `uvm_error("mult", "Assertion a_mulh_result failed")

   // check multiplication result for mulhsu
   a_mulhsu_result :
     assert property (@(posedge clk)
                      ((mulh_state == AHBH) && (operator_i == MUL_H) && (short_signed_i == 2'b01))
                      |->
                      (result_o == (($signed({{32{op_a_i[31]}}, op_a_i}) * {32'b0, op_b_i}) >> 32) ) )
       else `uvm_error("mult", "Assertion a_mulh_result failed")

   // check multiplication result for mulhu
   a_mulhu_result :
     assert property (@(posedge clk)
                      ((mulh_state == AHBH) && (operator_i == MUL_H) && (short_signed_i == 2'b00))
                      |->
                      (result_o == (({32'b0, op_a_i} * {32'b0, op_b_i}) >> 32) ) )
       else `uvm_error("mult", "Assertion a_mulh_result failed")

   // Check that multiplier inputs are not changed in the middle of a MULH operation
   a_enable_constant_when_mulh_active:
     assert property (@(posedge clk) disable iff (!rst_n)
                      !ready_o |=> $stable(enable_i)) else `uvm_error("mult", "Enable changed when MULH active")

   a_operator_constant_when_mulh_active:
     assert property (@(posedge clk) disable iff (!rst_n)
                      !ready_o |=> $stable(operator_i)) else `uvm_error("mult", "Operator changed when MULH active")

   a_sign_constant_when_mulh_active:
     assert property (@(posedge clk) disable iff (!rst_n)
                      !ready_o |=> $stable(short_signed_i)) else `uvm_error("mult", "Sign changed when MULH active")

   a_operand_a_constant_when_mulh_active:
     assert property (@(posedge clk) disable iff (!rst_n)
                      !ready_o |=> $stable(op_a_i)) else `uvm_error("mult", "Operand A changed when MULH active")

   a_operand_b_constant_when_mulh_active:
     assert property (@(posedge clk) disable iff (!rst_n)
                      !ready_o |=> $stable(op_b_i)) else `uvm_error("mult", "Operand B changed when MULH active")

endmodule // cv32e40x_mult
