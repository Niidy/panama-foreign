dnl Copyright (c) 2019, Red Hat Inc. All rights reserved.
dnl DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
dnl
dnl This code is free software; you can redistribute it and/or modify it
dnl under the terms of the GNU General Public License version 2 only, as
dnl published by the Free Software Foundation.
dnl
dnl This code is distributed in the hope that it will be useful, but WITHOUT
dnl ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
dnl FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
dnl version 2 for more details (a copy is included in the LICENSE file that
dnl accompanied this code).
dnl
dnl You should have received a copy of the GNU General Public License version
dnl 2 along with this work; if not, write to the Free Software Foundation,
dnl Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA.
dnl
dnl Please contact Oracle, 500 Oracle Parkway, Redwood Shores, CA 94065 USA
dnl or visit www.oracle.com if you need additional information or have any
dnl questions.
dnl
dnl
dnl Process this file with m4 aarch64_ad.m4 to generate instructions used in
dnl aarch64.ad:
dnl 1. the arithmetic
dnl 2. shift patterns
dnl 3. vector reduce and/or/eor
dnl
// BEGIN This section of the file is automatically generated. Do not edit --------------
dnl
define(`ORL2I', `ifelse($1,I,orL2I)')
dnl
define(`BASE_SHIFT_INSN',
`
instruct $2$1_reg_$4_reg(iReg$1NoSp dst,
                         iReg$1`'ORL2I($1) src1, iReg$1`'ORL2I($1) src2,
                         immI src3, rFlagsReg cr) %{
  match(Set dst ($2$1 src1 ($4$1 src2 src3)));

  ins_cost(1.9 * INSN_COST);
  format %{ "$3  $dst, $src1, $src2, $5 $src3" %}

  ins_encode %{
    __ $3(as_Register($dst$$reg),
              as_Register($src1$$reg),
              as_Register($src2$$reg),
              Assembler::$5,
              $src3$$constant & ifelse($1,I,0x1f,0x3f));
  %}

  ins_pipe(ialu_reg_reg_shift);
%}')dnl
define(`BASE_INVERTED_INSN',
`
instruct $2$1_reg_not_reg(iReg$1NoSp dst,
                         iReg$1`'ORL2I($1) src1, iReg$1`'ORL2I($1) src2, imm$1_M1 m1,
                         rFlagsReg cr) %{
dnl This ifelse is because hotspot reassociates (xor (xor ..)..)
dnl into this canonical form.
  ifelse($2,Xor,
    match(Set dst (Xor$1 m1 (Xor$1 src2 src1)));,
    match(Set dst ($2$1 src1 (Xor$1 src2 m1)));)
  ins_cost(INSN_COST);
  format %{ "$3  $dst, $src1, $src2" %}

  ins_encode %{
    __ $3(as_Register($dst$$reg),
              as_Register($src1$$reg),
              as_Register($src2$$reg),
              Assembler::LSL, 0);
  %}

  ins_pipe(ialu_reg_reg);
%}')dnl
define(`INVERTED_SHIFT_INSN',
`
instruct $2$1_reg_$4_not_reg(iReg$1NoSp dst,
                         iReg$1`'ORL2I($1) src1, iReg$1`'ORL2I($1) src2,
                         immI src3, imm$1_M1 src4, rFlagsReg cr) %{
dnl This ifelse is because hotspot reassociates (xor (xor ..)..)
dnl into this canonical form.
  ifelse($2,Xor,
    match(Set dst ($2$1 src4 (Xor$1($4$1 src2 src3) src1)));,
    match(Set dst ($2$1 src1 (Xor$1($4$1 src2 src3) src4)));)
  ins_cost(1.9 * INSN_COST);
  format %{ "$3  $dst, $src1, $src2, $5 $src3" %}

  ins_encode %{
    __ $3(as_Register($dst$$reg),
              as_Register($src1$$reg),
              as_Register($src2$$reg),
              Assembler::$5,
              $src3$$constant & ifelse($1,I,0x1f,0x3f));
  %}

  ins_pipe(ialu_reg_reg_shift);
%}')dnl
define(`NOT_INSN',
`instruct reg$1_not_reg(iReg$1NoSp dst,
                         iReg$1`'ORL2I($1) src1, imm$1_M1 m1,
                         rFlagsReg cr) %{
  match(Set dst (Xor$1 src1 m1));
  ins_cost(INSN_COST);
  format %{ "$2  $dst, $src1, zr" %}

  ins_encode %{
    __ $2(as_Register($dst$$reg),
              as_Register($src1$$reg),
              zr,
              Assembler::LSL, 0);
  %}

  ins_pipe(ialu_reg);
%}')dnl
dnl
define(`BOTH_SHIFT_INSNS',
`BASE_SHIFT_INSN(I, $1, ifelse($2,andr,andw,$2w), $3, $4)
BASE_SHIFT_INSN(L, $1, $2, $3, $4)')dnl
dnl
define(`BOTH_INVERTED_INSNS',
`BASE_INVERTED_INSN(I, $1, $2w, $3, $4)
BASE_INVERTED_INSN(L, $1, $2, $3, $4)')dnl
dnl
define(`BOTH_INVERTED_SHIFT_INSNS',
`INVERTED_SHIFT_INSN(I, $1, $2w, $3, $4, ~0, int)
INVERTED_SHIFT_INSN(L, $1, $2, $3, $4, ~0l, long)')dnl
dnl
define(`ALL_SHIFT_KINDS',
`BOTH_SHIFT_INSNS($1, $2, URShift, LSR)
BOTH_SHIFT_INSNS($1, $2, RShift, ASR)
BOTH_SHIFT_INSNS($1, $2, LShift, LSL)')dnl
dnl
define(`ALL_INVERTED_SHIFT_KINDS',
`BOTH_INVERTED_SHIFT_INSNS($1, $2, URShift, LSR)
BOTH_INVERTED_SHIFT_INSNS($1, $2, RShift, ASR)
BOTH_INVERTED_SHIFT_INSNS($1, $2, LShift, LSL)')dnl
dnl
NOT_INSN(L, eon)
NOT_INSN(I, eonw)
BOTH_INVERTED_INSNS(And, bic)
BOTH_INVERTED_INSNS(Or, orn)
BOTH_INVERTED_INSNS(Xor, eon)
ALL_INVERTED_SHIFT_KINDS(And, bic)
ALL_INVERTED_SHIFT_KINDS(Xor, eon)
ALL_INVERTED_SHIFT_KINDS(Or, orn)
ALL_SHIFT_KINDS(And, andr)
ALL_SHIFT_KINDS(Xor, eor)
ALL_SHIFT_KINDS(Or, orr)
ALL_SHIFT_KINDS(Add, add)
ALL_SHIFT_KINDS(Sub, sub)
dnl
dnl EXTEND mode, rshift_op, src, lshift_count, rshift_count
define(`EXTEND', `($2$1 (LShift$1 $3 $4) $5)')
define(`BFM_INSN',`
// Shift Left followed by Shift Right.
// This idiom is used by the compiler for the i2b bytecode etc.
instruct $4$1(iReg$1NoSp dst, iReg$1`'ORL2I($1) src, immI lshift_count, immI rshift_count)
%{
  match(Set dst EXTEND($1, $3, src, lshift_count, rshift_count));
  ins_cost(INSN_COST * 2);
  format %{ "$4  $dst, $src, $rshift_count - $lshift_count, #$2 - $lshift_count" %}
  ins_encode %{
    int lshift = $lshift_count$$constant & $2;
    int rshift = $rshift_count$$constant & $2;
    int s = $2 - lshift;
    int r = (rshift - lshift) & $2;
    __ $4(as_Register($dst$$reg),
            as_Register($src$$reg),
            r, s);
  %}

  ins_pipe(ialu_reg_shift);
%}')
BFM_INSN(L, 63, RShift, sbfm)
BFM_INSN(I, 31, RShift, sbfmw)
BFM_INSN(L, 63, URShift, ubfm)
BFM_INSN(I, 31, URShift, ubfmw)
dnl
// Bitfield extract with shift & mask
define(`BFX_INSN',
`instruct $3$1(iReg$1NoSp dst, iReg$1`'ORL2I($1) src, immI rshift, imm$1_bitmask mask)
%{
  match(Set dst (And$1 ($2$1 src rshift) mask));
  // Make sure we are not going to exceed what $3 can do.
  predicate((exact_log2$6(n->in(2)->get_$5() + 1) + (n->in(1)->in(2)->get_int() & $4)) <= ($4 + 1));

  ins_cost(INSN_COST);
  format %{ "$3 $dst, $src, $rshift, $mask" %}
  ins_encode %{
    int rshift = $rshift$$constant & $4;
    long mask = $mask$$constant;
    int width = exact_log2$6(mask+1);
    __ $3(as_Register($dst$$reg),
            as_Register($src$$reg), rshift, width);
  %}
  ins_pipe(ialu_reg_shift);
%}')
BFX_INSN(I, URShift, ubfxw, 31, int)
BFX_INSN(L, URShift, ubfx,  63, long, _long)

// We can use ubfx when extending an And with a mask when we know mask
// is positive.  We know that because immI_bitmask guarantees it.
instruct ubfxIConvI2L(iRegLNoSp dst, iRegIorL2I src, immI rshift, immI_bitmask mask)
%{
  match(Set dst (ConvI2L (AndI (URShiftI src rshift) mask)));
  // Make sure we are not going to exceed what ubfxw can do.
  predicate((exact_log2(n->in(1)->in(2)->get_int() + 1) + (n->in(1)->in(1)->in(2)->get_int() & 31)) <= (31 + 1));

  ins_cost(INSN_COST * 2);
  format %{ "ubfx $dst, $src, $rshift, $mask" %}
  ins_encode %{
    int rshift = $rshift$$constant & 31;
    long mask = $mask$$constant;
    int width = exact_log2(mask+1);
    __ ubfx(as_Register($dst$$reg),
            as_Register($src$$reg), rshift, width);
  %}
  ins_pipe(ialu_reg_shift);
%}

define(`UBFIZ_INSN',
// We can use ubfiz when masking by a positive number and then left shifting the result.
// We know that the mask is positive because imm$1_bitmask guarantees it.
`instruct $2$1(iReg$1NoSp dst, iReg$1`'ORL2I($1) src, immI lshift, imm$1_bitmask mask)
%{
  match(Set dst (LShift$1 (And$1 src mask) lshift));
  predicate((exact_log2$5(n->in(1)->in(2)->get_$4() + 1) + (n->in(2)->get_int() & $3)) <= ($3 + 1));

  ins_cost(INSN_COST);
  format %{ "$2 $dst, $src, $lshift, $mask" %}
  ins_encode %{
    int lshift = $lshift$$constant & $3;
    long mask = $mask$$constant;
    int width = exact_log2$5(mask+1);
    __ $2(as_Register($dst$$reg),
          as_Register($src$$reg), lshift, width);
  %}
  ins_pipe(ialu_reg_shift);
%}')dnl
UBFIZ_INSN(I, ubfizw, 31, int)
UBFIZ_INSN(L, ubfiz,  63, long, _long)

// If there is a convert I to L block between and AndI and a LShiftL, we can also match ubfiz
instruct ubfizIConvI2L(iRegLNoSp dst, iRegIorL2I src, immI lshift, immI_bitmask mask)
%{
  match(Set dst (LShiftL (ConvI2L (AndI src mask)) lshift));
  predicate((exact_log2(n->in(1)->in(1)->in(2)->get_int() + 1) + (n->in(2)->get_int() & 63)) <= (63 + 1));

  ins_cost(INSN_COST);
  format %{ "ubfiz $dst, $src, $lshift, $mask" %}
  ins_encode %{
    int lshift = $lshift$$constant & 63;
    long mask = $mask$$constant;
    int width = exact_log2(mask+1);
    __ ubfiz(as_Register($dst$$reg),
             as_Register($src$$reg), lshift, width);
  %}
  ins_pipe(ialu_reg_shift);
%}

// Rotations

define(`EXTRACT_INSN',
`instruct extr$3$1(iReg$1NoSp dst, iReg$1`'ORL2I($1) src1, iReg$1`'ORL2I($1) src2, immI lshift, immI rshift, rFlagsReg cr)
%{
  match(Set dst ($3$1 (LShift$1 src1 lshift) (URShift$1 src2 rshift)));
  predicate(0 == (((n->in(1)->in(2)->get_int() & $2) + (n->in(2)->in(2)->get_int() & $2)) & $2));

  ins_cost(INSN_COST);
  format %{ "extr $dst, $src1, $src2, #$rshift" %}

  ins_encode %{
    __ $4(as_Register($dst$$reg), as_Register($src1$$reg), as_Register($src2$$reg),
            $rshift$$constant & $2);
  %}
  ins_pipe(ialu_reg_reg_extr);
%}
')dnl
EXTRACT_INSN(L, 63, Or, extr)
EXTRACT_INSN(I, 31, Or, extrw)
EXTRACT_INSN(L, 63, Add, extr)
EXTRACT_INSN(I, 31, Add, extrw)
define(`ROL_EXPAND', `
// $2 expander

instruct $2$1_rReg(iReg$1NoSp dst, iReg$1 src, iRegI shift, rFlagsReg cr)
%{
  effect(DEF dst, USE src, USE shift);

  format %{ "$2    $dst, $src, $shift" %}
  ins_cost(INSN_COST * 3);
  ins_encode %{
    __ subw(rscratch1, zr, as_Register($shift$$reg));
    __ $3(as_Register($dst$$reg), as_Register($src$$reg),
            rscratch1);
    %}
  ins_pipe(ialu_reg_reg_vshift);
%}')dnl
define(`ROR_EXPAND', `
// $2 expander

instruct $2$1_rReg(iReg$1NoSp dst, iReg$1 src, iRegI shift, rFlagsReg cr)
%{
  effect(DEF dst, USE src, USE shift);

  format %{ "$2    $dst, $src, $shift" %}
  ins_cost(INSN_COST);
  ins_encode %{
    __ $3(as_Register($dst$$reg), as_Register($src$$reg),
            as_Register($shift$$reg));
    %}
  ins_pipe(ialu_reg_reg_vshift);
%}')dnl
define(ROL_INSN, `
instruct $3$1_rReg_Var_C$2(iReg$1NoSp dst, iReg$1 src, iRegI shift, immI$2 c$2, rFlagsReg cr)
%{
  match(Set dst (Or$1 (LShift$1 src shift) (URShift$1 src (SubI c$2 shift))));

  expand %{
    $3$1_rReg(dst, src, shift, cr);
  %}
%}')dnl
define(ROR_INSN, `
instruct $3$1_rReg_Var_C$2(iReg$1NoSp dst, iReg$1 src, iRegI shift, immI$2 c$2, rFlagsReg cr)
%{
  match(Set dst (Or$1 (URShift$1 src shift) (LShift$1 src (SubI c$2 shift))));

  expand %{
    $3$1_rReg(dst, src, shift, cr);
  %}
%}')dnl
ROL_EXPAND(L, rol, rorv)
ROL_EXPAND(I, rol, rorvw)
ROL_INSN(L, _64, rol)
ROL_INSN(L, 0, rol)
ROL_INSN(I, _32, rol)
ROL_INSN(I, 0, rol)
ROR_EXPAND(L, ror, rorv)
ROR_EXPAND(I, ror, rorvw)
ROR_INSN(L, _64, ror)
ROR_INSN(L, 0, ror)
ROR_INSN(I, _32, ror)
ROR_INSN(I, 0, ror)

// Add/subtract (extended)
dnl ADD_SUB_EXTENDED(mode, size, add node, shift node, insn, shift type, wordsize
define(`ADD_SUB_CONV', `
instruct $3Ext$1(iReg$2NoSp dst, iReg$2`'ORL2I($2) src1, iReg$1`'ORL2I($1) src2, rFlagsReg cr)
%{
  match(Set dst ($3$2 src1 (ConvI2L src2)));
  ins_cost(INSN_COST);
  format %{ "$4  $dst, $src1, $src2, $5" %}

   ins_encode %{
     __ $4(as_Register($dst$$reg), as_Register($src1$$reg),
            as_Register($src2$$reg), ext::$5);
   %}
  ins_pipe(ialu_reg_reg);
%}')dnl
ADD_SUB_CONV(I,L,Add,add,sxtw);
ADD_SUB_CONV(I,L,Sub,sub,sxtw);
dnl
define(`ADD_SUB_EXTENDED', `
instruct $3Ext$1_$6(iReg$1NoSp dst, iReg$1`'ORL2I($1) src1, iReg$1`'ORL2I($1) src2, immI_`'eval($7-$2) lshift, immI_`'eval($7-$2) rshift, rFlagsReg cr)
%{
  match(Set dst ($3$1 src1 EXTEND($1, $4, src2, lshift, rshift)));
  ins_cost(INSN_COST);
  format %{ "$5  $dst, $src1, $src2, $6" %}

   ins_encode %{
     __ $5(as_Register($dst$$reg), as_Register($src1$$reg),
            as_Register($src2$$reg), ext::$6);
   %}
  ins_pipe(ialu_reg_reg);
%}')
ADD_SUB_EXTENDED(I,16,Add,RShift,add,sxth,32)
ADD_SUB_EXTENDED(I,8,Add,RShift,add,sxtb,32)
ADD_SUB_EXTENDED(I,8,Add,URShift,add,uxtb,32)
ADD_SUB_EXTENDED(L,16,Add,RShift,add,sxth,64)
ADD_SUB_EXTENDED(L,32,Add,RShift,add,sxtw,64)
ADD_SUB_EXTENDED(L,8,Add,RShift,add,sxtb,64)
ADD_SUB_EXTENDED(L,8,Add,URShift,add,uxtb,64)
dnl
dnl ADD_SUB_ZERO_EXTEND(mode, size, add node, insn, shift type)
define(`ADD_SUB_ZERO_EXTEND', `
instruct $3Ext$1_$5_and(iReg$1NoSp dst, iReg$1`'ORL2I($1) src1, iReg$1`'ORL2I($1) src2, imm$1_$2 mask, rFlagsReg cr)
%{
  match(Set dst ($3$1 src1 (And$1 src2 mask)));
  ins_cost(INSN_COST);
  format %{ "$4  $dst, $src1, $src2, $5" %}

   ins_encode %{
     __ $4(as_Register($dst$$reg), as_Register($src1$$reg),
            as_Register($src2$$reg), ext::$5);
   %}
  ins_pipe(ialu_reg_reg);
%}')
dnl
ADD_SUB_ZERO_EXTEND(I,255,Add,addw,uxtb)
ADD_SUB_ZERO_EXTEND(I,65535,Add,addw,uxth)
ADD_SUB_ZERO_EXTEND(L,255,Add,add,uxtb)
ADD_SUB_ZERO_EXTEND(L,65535,Add,add,uxth)
ADD_SUB_ZERO_EXTEND(L,4294967295,Add,add,uxtw)
dnl
ADD_SUB_ZERO_EXTEND(I,255,Sub,subw,uxtb)
ADD_SUB_ZERO_EXTEND(I,65535,Sub,subw,uxth)
ADD_SUB_ZERO_EXTEND(L,255,Sub,sub,uxtb)
ADD_SUB_ZERO_EXTEND(L,65535,Sub,sub,uxth)
ADD_SUB_ZERO_EXTEND(L,4294967295,Sub,sub,uxtw)
dnl
dnl ADD_SUB_ZERO_EXTEND_SHIFT(mode, size, add node, insn, ext type)
define(`ADD_SUB_EXTENDED_SHIFT', `
instruct $3Ext$1_$6_shift(iReg$1NoSp dst, iReg$1`'ORL2I($1) src1, iReg$1`'ORL2I($1) src2, immIExt lshift2, immI_`'eval($7-$2) lshift1, immI_`'eval($7-$2) rshift1, rFlagsReg cr)
%{
  match(Set dst ($3$1 src1 (LShift$1 EXTEND($1, $4, src2, lshift1, rshift1) lshift2)));
  ins_cost(1.9 * INSN_COST);
  format %{ "$5  $dst, $src1, $src2, $6 #lshift2" %}

   ins_encode %{
     __ $5(as_Register($dst$$reg), as_Register($src1$$reg),
            as_Register($src2$$reg), ext::$6, ($lshift2$$constant));
   %}
  ins_pipe(ialu_reg_reg_shift);
%}')
dnl                   $1 $2 $3   $4   $5   $6  $7
ADD_SUB_EXTENDED_SHIFT(L,8,Add,RShift,add,sxtb,64)
ADD_SUB_EXTENDED_SHIFT(L,16,Add,RShift,add,sxth,64)
ADD_SUB_EXTENDED_SHIFT(L,32,Add,RShift,add,sxtw,64)
dnl
ADD_SUB_EXTENDED_SHIFT(L,8,Sub,RShift,sub,sxtb,64)
ADD_SUB_EXTENDED_SHIFT(L,16,Sub,RShift,sub,sxth,64)
ADD_SUB_EXTENDED_SHIFT(L,32,Sub,RShift,sub,sxtw,64)
dnl
ADD_SUB_EXTENDED_SHIFT(I,8,Add,RShift,addw,sxtb,32)
ADD_SUB_EXTENDED_SHIFT(I,16,Add,RShift,addw,sxth,32)
dnl
ADD_SUB_EXTENDED_SHIFT(I,8,Sub,RShift,subw,sxtb,32)
ADD_SUB_EXTENDED_SHIFT(I,16,Sub,RShift,subw,sxth,32)
dnl
dnl ADD_SUB_CONV_SHIFT(mode, add node, insn, ext type)
define(`ADD_SUB_CONV_SHIFT', `
instruct $2ExtI_shift(iReg$1NoSp dst, iReg$1`'ORL2I($1) src1, iRegIorL2I src2, immIExt lshift, rFlagsReg cr)
%{
  match(Set dst ($2$1 src1 (LShiftL (ConvI2L src2) lshift)));
  ins_cost(1.9 * INSN_COST);
  format %{ "$3  $dst, $src1, $src2, $4 #lshift" %}

   ins_encode %{
     __ $3(as_Register($dst$$reg), as_Register($src1$$reg),
            as_Register($src2$$reg), ext::$4, ($lshift$$constant));
   %}
  ins_pipe(ialu_reg_reg_shift);
%}')
dnl
ADD_SUB_CONV_SHIFT(L,Add,add,sxtw);
ADD_SUB_CONV_SHIFT(L,Sub,sub,sxtw);
dnl
dnl ADD_SUB_ZERO_EXTEND(mode, size, add node, insn, ext type)
define(`ADD_SUB_ZERO_EXTEND_SHIFT', `
instruct $3Ext$1_$5_and_shift(iReg$1NoSp dst, iReg$1`'ORL2I($1) src1, iReg$1`'ORL2I($1) src2, imm$1_$2 mask, immIExt lshift, rFlagsReg cr)
%{
  match(Set dst ($3$1 src1 (LShift$1 (And$1 src2 mask) lshift)));
  ins_cost(1.9 * INSN_COST);
  format %{ "$4  $dst, $src1, $src2, $5 #lshift" %}

   ins_encode %{
     __ $4(as_Register($dst$$reg), as_Register($src1$$reg),
            as_Register($src2$$reg), ext::$5, ($lshift$$constant));
   %}
  ins_pipe(ialu_reg_reg_shift);
%}')
dnl
dnl                       $1 $2  $3  $4  $5
ADD_SUB_ZERO_EXTEND_SHIFT(L,255,Add,add,uxtb)
ADD_SUB_ZERO_EXTEND_SHIFT(L,65535,Add,add,uxth)
ADD_SUB_ZERO_EXTEND_SHIFT(L,4294967295,Add,add,uxtw)
dnl
ADD_SUB_ZERO_EXTEND_SHIFT(L,255,Sub,sub,uxtb)
ADD_SUB_ZERO_EXTEND_SHIFT(L,65535,Sub,sub,uxth)
ADD_SUB_ZERO_EXTEND_SHIFT(L,4294967295,Sub,sub,uxtw)
dnl
ADD_SUB_ZERO_EXTEND_SHIFT(I,255,Add,addw,uxtb)
ADD_SUB_ZERO_EXTEND_SHIFT(I,65535,Add,addw,uxth)
dnl
ADD_SUB_ZERO_EXTEND_SHIFT(I,255,Sub,subw,uxtb)
ADD_SUB_ZERO_EXTEND_SHIFT(I,65535,Sub,subw,uxth)
dnl
define(`REDUCE_LOGIC_OP_8B', `
instruct reduce_$1`'8B(iRegINoSp dst, iRegIorL2I src1, vecD src2, iRegINoSp tmp)
%{
  predicate(n->in(2)->bottom_type()->is_vect()->element_basic_type() == T_BYTE);
  match(Set dst ($2ReductionV src1 src2));
  ins_cost(INSN_COST);
  effect(TEMP_DEF dst, TEMP tmp);
  format %{ "umov   $tmp, $src2, S, 0\n\t"
            "umov   $dst, $src2, S, 1\n\t"
            "$1w   $dst, $dst, $tmp\n\t"
            "$1w   $dst, $dst, $dst, LSR #16\n\t"
            "$1w   $dst, $dst, $dst, LSR #8\n\t"
            "$1w   $dst, $src1, $dst\n\t"
            "sxtb   $dst, $dst\t $1 reduction8B"
  %}
  ins_encode %{
    __ umov($tmp$$Register, as_FloatRegister($src2$$reg), __ S, 0);
    __ umov($dst$$Register, as_FloatRegister($src2$$reg), __ S, 1);
    __ $1w($dst$$Register, $dst$$Register, $tmp$$Register);
    __ $1w($dst$$Register, $dst$$Register, $dst$$Register, Assembler::LSR, 16);
    __ $1w($dst$$Register, $dst$$Register, $dst$$Register, Assembler::LSR, 8);
    __ $1w($dst$$Register, $src1$$Register, $dst$$Register);
    __ sxtb($dst$$Register, $dst$$Register);
  %}
  ins_pipe(pipe_class_default);
%}')dnl
dnl                $1   $2
REDUCE_LOGIC_OP_8B(and, And)
REDUCE_LOGIC_OP_8B(orr, Or)
REDUCE_LOGIC_OP_8B(eor, Xor)
define(`REDUCE_LOGIC_OP_16B', `
instruct reduce_$1`'16B(iRegINoSp dst, iRegIorL2I src1, vecX src2, iRegINoSp tmp)
%{
  predicate(n->in(2)->bottom_type()->is_vect()->element_basic_type() == T_BYTE);
  match(Set dst ($2ReductionV src1 src2));
  ins_cost(INSN_COST);
  effect(TEMP_DEF dst, TEMP tmp);
  format %{ "umov   $tmp, $src2, D, 0\n\t"
            "umov   $dst, $src2, D, 1\n\t"
            "$3   $dst, $dst, $tmp\n\t"
            "$3   $dst, $dst, $dst, LSR #32\n\t"
            "$1w   $dst, $dst, $dst, LSR #16\n\t"
            "$1w   $dst, $dst, $dst, LSR #8\n\t"
            "$1w   $dst, $src1, $dst\n\t"
            "sxtb   $dst, $dst\t $1 reduction16B"
  %}
  ins_encode %{
    __ umov($tmp$$Register, as_FloatRegister($src2$$reg), __ D, 0);
    __ umov($dst$$Register, as_FloatRegister($src2$$reg), __ D, 1);
    __ $3($dst$$Register, $dst$$Register, $tmp$$Register);
    __ $3($dst$$Register, $dst$$Register, $dst$$Register, Assembler::LSR, 32);
    __ $1w($dst$$Register, $dst$$Register, $dst$$Register, Assembler::LSR, 16);
    __ $1w($dst$$Register, $dst$$Register, $dst$$Register, Assembler::LSR, 8);
    __ $1w($dst$$Register, $src1$$Register, $dst$$Register);
    __ sxtb($dst$$Register, $dst$$Register);
  %}
  ins_pipe(pipe_class_default);
%}')dnl
dnl                 $1   $2   $3
REDUCE_LOGIC_OP_16B(and, And, andr)
REDUCE_LOGIC_OP_16B(orr, Or,  orr )
REDUCE_LOGIC_OP_16B(eor, Xor, eor )
dnl
define(`REDUCE_LOGIC_OP_4S', `
instruct reduce_$1`'4S(iRegINoSp dst, iRegIorL2I src1, vecD src2, iRegINoSp tmp)
%{
  predicate(n->in(2)->bottom_type()->is_vect()->element_basic_type() == T_SHORT);
  match(Set dst ($2ReductionV src1 src2));
  ins_cost(INSN_COST);
  effect(TEMP_DEF dst, TEMP tmp);
  format %{ "umov   $tmp, $src2, S, 0\n\t"
            "umov   $dst, $src2, S, 1\n\t"
            "$1w   $dst, $dst, $tmp\n\t"
            "$1w   $dst, $dst, $dst, LSR #16\n\t"
            "$1w   $dst, $src1, $dst\n\t"
            "sxth   $dst, $dst\t $1 reduction4S"
  %}
  ins_encode %{
    __ umov($tmp$$Register, as_FloatRegister($src2$$reg), __ S, 0);
    __ umov($dst$$Register, as_FloatRegister($src2$$reg), __ S, 1);
    __ $1w($dst$$Register, $dst$$Register, $tmp$$Register);
    __ $1w($dst$$Register, $dst$$Register, $dst$$Register, Assembler::LSR, 16);
    __ $1w($dst$$Register, $src1$$Register, $dst$$Register);
    __ sxth($dst$$Register, $dst$$Register);
  %}
  ins_pipe(pipe_class_default);
%}')dnl
dnl                $1   $2
REDUCE_LOGIC_OP_4S(and, And)
REDUCE_LOGIC_OP_4S(orr, Or)
REDUCE_LOGIC_OP_4S(eor, Xor)
dnl
define(`REDUCE_LOGIC_OP_8S', `
instruct reduce_$1`'8S(iRegINoSp dst, iRegIorL2I src1, vecX src2, iRegINoSp tmp)
%{
  predicate(n->in(2)->bottom_type()->is_vect()->element_basic_type() == T_SHORT);
  match(Set dst ($2ReductionV src1 src2));
  ins_cost(INSN_COST);
  effect(TEMP_DEF dst, TEMP tmp);
  format %{ "umov   $tmp, $src2, D, 0\n\t"
            "umov   $dst, $src2, D, 1\n\t"
            "$3   $dst, $dst, $tmp\n\t"
            "$3   $dst, $dst, $dst, LSR #32\n\t"
            "$1w   $dst, $dst, $dst, LSR #16\n\t"
            "$1w   $dst, $src1, $dst\n\t"
            "sxth   $dst, $dst\t $1 reduction8S"
  %}
  ins_encode %{
    __ umov($tmp$$Register, as_FloatRegister($src2$$reg), __ D, 0);
    __ umov($dst$$Register, as_FloatRegister($src2$$reg), __ D, 1);
    __ $3($dst$$Register, $dst$$Register, $tmp$$Register);
    __ $3($dst$$Register, $dst$$Register, $dst$$Register, Assembler::LSR, 32);
    __ $1w($dst$$Register, $dst$$Register, $dst$$Register, Assembler::LSR, 16);
    __ $1w($dst$$Register, $src1$$Register, $dst$$Register);
    __ sxth($dst$$Register, $dst$$Register);
  %}
  ins_pipe(pipe_class_default);
%}')dnl
dnl                $1   $2   $3
REDUCE_LOGIC_OP_8S(and, And, andr)
REDUCE_LOGIC_OP_8S(orr, Or,  orr )
REDUCE_LOGIC_OP_8S(eor, Xor, eor )
dnl
define(`REDUCE_LOGIC_OP_2I', `
instruct reduce_$1`'2I(iRegINoSp dst, iRegIorL2I src1, vecD src2, iRegINoSp tmp)
%{
  predicate(n->in(2)->bottom_type()->is_vect()->element_basic_type() == T_INT);
  match(Set dst ($2ReductionV src1 src2));
  ins_cost(INSN_COST);
  effect(TEMP_DEF dst, TEMP tmp);
  format %{ "umov  $tmp, $src2, S, 0\n\t"
            "$1w  $dst, $tmp, $src1\n\t"
            "umov  $tmp, $src2, S, 1\n\t"
            "$1w  $dst, $tmp, $dst\t $1 reduction2I"
  %}
  ins_encode %{
    __ umov($tmp$$Register, as_FloatRegister($src2$$reg), __ S, 0);
    __ $1w($dst$$Register, $tmp$$Register, $src1$$Register);
    __ umov($tmp$$Register, as_FloatRegister($src2$$reg), __ S, 1);
    __ $1w($dst$$Register, $tmp$$Register, $dst$$Register);
  %}
  ins_pipe(pipe_class_default);
%}')dnl
dnl                $1   $2
REDUCE_LOGIC_OP_2I(and, And)
REDUCE_LOGIC_OP_2I(orr, Or)
REDUCE_LOGIC_OP_2I(eor, Xor)
dnl
define(`REDUCE_LOGIC_OP_4I', `
instruct reduce_$1`'4I(iRegINoSp dst, iRegIorL2I src1, vecX src2, iRegINoSp tmp)
%{
  predicate(n->in(2)->bottom_type()->is_vect()->element_basic_type() == T_INT);
  match(Set dst ($2ReductionV src1 src2));
  ins_cost(INSN_COST);
  effect(TEMP_DEF dst, TEMP tmp);
  format %{ "umov   $tmp, $src2, D, 0\n\t"
            "umov   $dst, $src2, D, 1\n\t"
            "$3   $dst, $dst, $tmp\n\t"
            "$3   $dst, $dst, $dst, LSR #32\n\t"
            "$1w   $dst, $src1, $dst\t $1 reduction4I"
  %}
  ins_encode %{
    __ umov($tmp$$Register, as_FloatRegister($src2$$reg), __ D, 0);
    __ umov($dst$$Register, as_FloatRegister($src2$$reg), __ D, 1);
    __ $3($dst$$Register, $dst$$Register, $tmp$$Register);
    __ $3($dst$$Register, $dst$$Register, $dst$$Register, Assembler::LSR, 32);
    __ $1w($dst$$Register, $src1$$Register, $dst$$Register);
  %}
  ins_pipe(pipe_class_default);
%}')dnl
dnl                $1   $2   $3
REDUCE_LOGIC_OP_4I(and, And, andr)
REDUCE_LOGIC_OP_4I(orr, Or,  orr )
REDUCE_LOGIC_OP_4I(eor, Xor, eor )
dnl
define(`REDUCE_LOGIC_OP_2L', `
instruct reduce_$1`'2L(iRegLNoSp dst, iRegL src1, vecX src2, iRegLNoSp tmp)
%{
  predicate(n->in(2)->bottom_type()->is_vect()->element_basic_type() == T_LONG);
  match(Set dst ($2ReductionV src1 src2));
  ins_cost(INSN_COST);
  effect(TEMP_DEF dst, TEMP tmp);
  format %{ "umov  $tmp, $src2, D, 0\n\t"
            "$3  $dst, $src1, $tmp\n\t"
            "umov  $tmp, $src2, D, 1\n\t"
            "$3  $dst, $dst, $tmp\t $1 reduction2L"
  %}
  ins_encode %{
    __ umov($tmp$$Register, as_FloatRegister($src2$$reg), __ D, 0);
    __ $3($dst$$Register, $src1$$Register, $tmp$$Register);
    __ umov($tmp$$Register, as_FloatRegister($src2$$reg), __ D, 1);
    __ $3($dst$$Register, $dst$$Register, $tmp$$Register);
  %}
  ins_pipe(pipe_class_default);
%}')dnl
dnl                $1   $2   $3
REDUCE_LOGIC_OP_2L(and, And, andr)
REDUCE_LOGIC_OP_2L(orr, Or,  orr )
REDUCE_LOGIC_OP_2L(eor, Xor, eor )
dnl

// ------------------------------ Vector insert ---------------------------------
define(`VECTOR_INSERT_I', `
instruct insert$1`'(vec$2 dst, vec$2 src, iReg$3`'ORL2I($3) val, immI idx)
%{
  predicate(n->bottom_type()->is_vect()->element_basic_type() == T_$4);
  match(Set dst (VectorInsert (Binary src val) idx));
  ins_cost(INSN_COST);
  format %{ "orr    $dst, T$5, $src, $src\n\t"
            "mov    $dst, T$6, $idx, $val\t# insert into vector($1)" %}
  ins_encode %{
    if (as_FloatRegister($dst$$reg) != as_FloatRegister($src$$reg)) {
      __ orr(as_FloatRegister($dst$$reg), __ T$5,
             as_FloatRegister($src$$reg), as_FloatRegister($src$$reg));
    }
    __ mov(as_FloatRegister($dst$$reg), __ T$6, $idx$$constant, $val$$Register);
  %}
  ins_pipe(pipe_class_default);
%}')dnl
dnl             $1   $2 $3  $4    $5   $6
VECTOR_INSERT_I(8B,  D, I, BYTE,  8B,  8B)
VECTOR_INSERT_I(16B, X, I, BYTE,  16B, 16B)
VECTOR_INSERT_I(4S,  D, I, SHORT, 8B,  4H)
VECTOR_INSERT_I(8S,  X, I, SHORT, 16B, 8H)
VECTOR_INSERT_I(2I,  D, I, INT,   8B,  2S)
VECTOR_INSERT_I(4I,  X, I, INT,   16B, 4S)
VECTOR_INSERT_I(2L,  X, L, LONG,  16B, 2D)
dnl
define(`VECTOR_INSERT_F', `
instruct insert$1`'(vec$2 dst, vec$2 src, vReg$3 val, immI idx)
%{
  predicate(n->bottom_type()->is_vect()->element_basic_type() == T_$4);
  match(Set dst (VectorInsert (Binary src val) idx));
  ins_cost(INSN_COST);
  format %{ "orr    $dst, T$5, $src, $src\n\t"
            "ins    $dst, $6, $val, $idx, 0\t# insert into vector($1)" %}
  ins_encode %{
    if (as_FloatRegister($dst$$reg) != as_FloatRegister($src$$reg)) {
      __ orr(as_FloatRegister($dst$$reg), __ T$5,
             as_FloatRegister($src$$reg), as_FloatRegister($src$$reg));
    }
    __ ins(as_FloatRegister($dst$$reg), __ $6,
           as_FloatRegister($val$$reg), $idx$$constant, 0);
  %}
  ins_pipe(pipe_class_default);
%}')dnl
dnl             $1  $2 $3  $4     $5   $6
VECTOR_INSERT_F(2F, D, F, FLOAT,  8B,  S)
VECTOR_INSERT_F(4F, X, F, FLOAT,  16B, S)
VECTOR_INSERT_F(2D, X, D, DOUBLE, 16B, D)
dnl

// ------------------------------ Vector extract ---------------------------------
define(`VECTOR_EXTRACT_I', `
instruct extract$1$2`'(iReg$3NoSp dst, vec$4 src, immI idx)
%{
  predicate(n->in(1)->bottom_type()->is_vect()->length() == $1);
  match(Set dst (Extract$2 src idx));
  ins_cost(INSN_COST);
  format %{ "$5mov    $dst, $src, $6, $idx\t# extract from vector($1$2)" %}
  ins_encode %{
    __ $5mov($dst$$Register, as_FloatRegister($src$$reg), __ $6, $idx$$constant);
  %}
  ins_pipe(pipe_class_default);
%}')dnl
dnl             $1   $2 $3 $4 $5 $6
VECTOR_EXTRACT_I(8,  B, I, D, s, B)
VECTOR_EXTRACT_I(16, B, I, X, s, B)
VECTOR_EXTRACT_I(4,  S, I, D, s, H)
VECTOR_EXTRACT_I(8,  S, I, X, s, H)
VECTOR_EXTRACT_I(2,  I, I, D, u, S)
VECTOR_EXTRACT_I(4,  I, I, X, u, S)
VECTOR_EXTRACT_I(2,  L, L, X, u, D)
dnl
define(`VECTOR_EXTRACT_F', `
instruct extract$1$2`'(vReg$2 dst, vec$3 src, immI idx)
%{
  predicate(n->in(1)->bottom_type()->is_vect()->length() == $1);
  match(Set dst (Extract$2 src idx));
  ins_cost(INSN_COST);
  format %{ "ins   $dst, $4, $src, 0, $idx\t# extract from vector($1$2)" %}
  ins_encode %{
    __ ins(as_FloatRegister($dst$$reg), __ $4,
           as_FloatRegister($src$$reg), 0, $idx$$constant);
  %}
  ins_pipe(pipe_class_default);
%}')dnl
dnl             $1  $2 $3 $4
VECTOR_EXTRACT_F(2, F, D, S)
VECTOR_EXTRACT_F(4, F, X, S)
VECTOR_EXTRACT_F(2, D, X, D)
dnl
// END This section of the file is automatically generated. Do not edit --------------
