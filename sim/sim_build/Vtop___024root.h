// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design internal header
// See Vtop.h for the primary calling header

#ifndef VERILATED_VTOP___024ROOT_H_
#define VERILATED_VTOP___024ROOT_H_  // guard

#include "verilated.h"


class Vtop__Syms;

class alignas(VL_CACHE_LINE_BYTES) Vtop___024root final : public VerilatedModule {
  public:

    // DESIGN SPECIFIC STATE
    VL_IN8(clk_i,0,0);
    VL_IN8(rst_i,0,0);
    VL_IN8(wr_en_i,0,0);
    VL_IN8(rd_en_i,0,0);
    VL_OUT8(full_o,0,0);
    VL_OUT8(empty_o,0,0);
    CData/*0:0*/ fifo__DOT__clk_i;
    CData/*0:0*/ fifo__DOT__rst_i;
    CData/*0:0*/ fifo__DOT__wr_en_i;
    CData/*0:0*/ fifo__DOT__rd_en_i;
    CData/*0:0*/ fifo__DOT__full_o;
    CData/*0:0*/ fifo__DOT__empty_o;
    CData/*4:0*/ fifo__DOT__rd_ptr;
    CData/*4:0*/ fifo__DOT__wr_ptr;
    CData/*0:0*/ fifo__DOT__rd_valid;
    CData/*0:0*/ fifo__DOT__wr_valid;
    CData/*0:0*/ __VstlFirstIteration;
    CData/*0:0*/ __VicoFirstIteration;
    CData/*0:0*/ __Vtrigprevexpr___TOP__clk_i__0;
    CData/*0:0*/ __VactContinue;
    VL_IN(wr_data_i,31,0);
    VL_OUT(rd_data_o,31,0);
    IData/*31:0*/ fifo__DOT__wr_data_i;
    IData/*31:0*/ fifo__DOT__rd_data_o;
    IData/*31:0*/ __VactIterCount;
    VlUnpacked<IData/*31:0*/, 16> fifo__DOT__mem;
    VlTriggerVec<1> __VstlTriggered;
    VlTriggerVec<1> __VicoTriggered;
    VlTriggerVec<1> __VactTriggered;
    VlTriggerVec<1> __VnbaTriggered;

    // INTERNAL VARIABLES
    Vtop__Syms* const vlSymsp;

    // PARAMETERS
    static constexpr IData/*31:0*/ fifo__DOT__DataWidth = 0x00000020U;
    static constexpr IData/*31:0*/ fifo__DOT__Depth = 0x00000010U;
    static constexpr IData/*31:0*/ fifo__DOT__PointerWidth = 4U;

    // CONSTRUCTORS
    Vtop___024root(Vtop__Syms* symsp, const char* v__name);
    ~Vtop___024root();
    VL_UNCOPYABLE(Vtop___024root);

    // INTERNAL METHODS
    void __Vconfigure(bool first);
};


#endif  // guard
