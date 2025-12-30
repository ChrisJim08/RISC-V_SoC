// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design internal header
// See Vtop.h for the primary calling header

#ifndef VERILATED_VTOP___024ROOT_H_
#define VERILATED_VTOP___024ROOT_H_  // guard

#include "verilated.h"
class Vtop___024unit;


class Vtop__Syms;

class alignas(VL_CACHE_LINE_BYTES) Vtop___024root final : public VerilatedModule {
  public:
    // CELLS
    Vtop___024unit* __PVT____024unit;

    // DESIGN SPECIFIC STATE
    VL_IN8(clk_i,0,0);
    VL_IN8(rst_i,0,0);
    VL_IN8(tick_i,0,0);
    VL_IN8(dv_i,0,0);
    VL_IN8(data_i,7,0);
    VL_OUT8(txd_o,0,0);
    VL_OUT8(busy_o,0,0);
    CData/*0:0*/ uart_tx__DOT__clk_i;
    CData/*0:0*/ uart_tx__DOT__rst_i;
    CData/*0:0*/ uart_tx__DOT__tick_i;
    CData/*0:0*/ uart_tx__DOT__dv_i;
    CData/*7:0*/ uart_tx__DOT__data_i;
    CData/*0:0*/ uart_tx__DOT__txd_o;
    CData/*0:0*/ uart_tx__DOT__busy_o;
    CData/*7:0*/ uart_tx__DOT__sbuff_reg;
    CData/*7:0*/ uart_tx__DOT__next_sbuff;
    CData/*2:0*/ uart_tx__DOT__count_reg;
    CData/*2:0*/ uart_tx__DOT__next_count;
    CData/*0:0*/ uart_tx__DOT__sbuff_empty;
    CData/*0:0*/ __VstlFirstIteration;
    CData/*0:0*/ __VicoFirstIteration;
    CData/*0:0*/ __Vtrigprevexpr___TOP__clk_i__0;
    CData/*0:0*/ __Vtrigprevexpr___TOP__rst_i__0;
    CData/*0:0*/ __VactContinue;
    IData/*31:0*/ uart_tx__DOT__state_reg;
    IData/*31:0*/ uart_tx__DOT__next_state;
    IData/*31:0*/ __VactIterCount;
    VlTriggerVec<1> __VstlTriggered;
    VlTriggerVec<1> __VicoTriggered;
    VlTriggerVec<2> __VactTriggered;
    VlTriggerVec<2> __VnbaTriggered;

    // INTERNAL VARIABLES
    Vtop__Syms* const vlSymsp;

    // PARAMETERS
    static constexpr IData/*31:0*/ uart_tx__DOT__DataWidth = 8U;
    static constexpr IData/*31:0*/ uart_tx__DOT__CountWidth = 3U;

    // CONSTRUCTORS
    Vtop___024root(Vtop__Syms* symsp, const char* v__name);
    ~Vtop___024root();
    VL_UNCOPYABLE(Vtop___024root);

    // INTERNAL METHODS
    void __Vconfigure(bool first);
};


#endif  // guard
