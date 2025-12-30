// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Symbol table implementation internals

#include "Vtop__pch.h"
#include "Vtop.h"
#include "Vtop___024root.h"
#include "Vtop___024unit.h"

// FUNCTIONS
Vtop__Syms::~Vtop__Syms()
{

    // Tear down scope hierarchy
    __Vhier.remove(0, &__Vscope___024unit);
    __Vhier.remove(0, &__Vscope_uart_tx);

}

Vtop__Syms::Vtop__Syms(VerilatedContext* contextp, const char* namep, Vtop* modelp)
    : VerilatedSyms{contextp}
    // Setup internal state of the Syms class
    , __Vm_modelp{modelp}
    // Setup module instances
    , TOP{this, namep}
    , TOP____024unit{this, Verilated::catName(namep, "$unit")}
{
        // Check resources
        Verilated::stackCheck(25);
    // Configure time unit / time precision
    _vm_contextp__->timeunit(-9);
    _vm_contextp__->timeprecision(-12);
    // Setup each module's pointers to their submodules
    TOP.__PVT____024unit = &TOP____024unit;
    // Setup each module's pointer back to symbol table (for public functions)
    TOP.__Vconfigure(true);
    TOP____024unit.__Vconfigure(true);
    // Setup scopes
    __Vscope_TOP.configure(this, name(), "TOP", "TOP", "<null>", 0, VerilatedScope::SCOPE_OTHER);
    __Vscope___024unit.configure(this, name(), "\\$unit ", "\\$unit ", "__024unit", -9, VerilatedScope::SCOPE_PACKAGE);
    __Vscope_uart_tx.configure(this, name(), "uart_tx", "uart_tx", "uart_tx", -9, VerilatedScope::SCOPE_MODULE);

    // Set up scope hierarchy
    __Vhier.add(0, &__Vscope___024unit);
    __Vhier.add(0, &__Vscope_uart_tx);

    // Setup export functions
    for (int __Vfinal = 0; __Vfinal < 2; ++__Vfinal) {
        __Vscope_TOP.varInsert(__Vfinal,"busy_o", &(TOP.busy_o), false, VLVT_UINT8,VLVD_OUT|VLVF_PUB_RW,0,0);
        __Vscope_TOP.varInsert(__Vfinal,"clk_i", &(TOP.clk_i), false, VLVT_UINT8,VLVD_IN|VLVF_PUB_RW,0,0);
        __Vscope_TOP.varInsert(__Vfinal,"data_i", &(TOP.data_i), false, VLVT_UINT8,VLVD_IN|VLVF_PUB_RW,0,1 ,7,0);
        __Vscope_TOP.varInsert(__Vfinal,"dv_i", &(TOP.dv_i), false, VLVT_UINT8,VLVD_IN|VLVF_PUB_RW,0,0);
        __Vscope_TOP.varInsert(__Vfinal,"rst_i", &(TOP.rst_i), false, VLVT_UINT8,VLVD_IN|VLVF_PUB_RW,0,0);
        __Vscope_TOP.varInsert(__Vfinal,"tick_i", &(TOP.tick_i), false, VLVT_UINT8,VLVD_IN|VLVF_PUB_RW,0,0);
        __Vscope_TOP.varInsert(__Vfinal,"txd_o", &(TOP.txd_o), false, VLVT_UINT8,VLVD_OUT|VLVF_PUB_RW,0,0);
        __Vscope___024unit.varInsert(__Vfinal,"BAUD_115200_RATE", const_cast<void*>(static_cast<const void*>(&(TOP____024unit.BAUD_115200_RATE))), true, VLVT_UINT32,VLVD_NODIR|VLVF_PUB_RW|VLVF_DPI_CLAY,0,1 ,31,0);
        __Vscope___024unit.varInsert(__Vfinal,"BAUD_1900_RATE", const_cast<void*>(static_cast<const void*>(&(TOP____024unit.BAUD_1900_RATE))), true, VLVT_UINT32,VLVD_NODIR|VLVF_PUB_RW|VLVF_DPI_CLAY,0,1 ,31,0);
        __Vscope___024unit.varInsert(__Vfinal,"BAUD_19200_RATE", const_cast<void*>(static_cast<const void*>(&(TOP____024unit.BAUD_19200_RATE))), true, VLVT_UINT32,VLVD_NODIR|VLVF_PUB_RW|VLVF_DPI_CLAY,0,1 ,31,0);
        __Vscope___024unit.varInsert(__Vfinal,"BAUD_57600_RATE", const_cast<void*>(static_cast<const void*>(&(TOP____024unit.BAUD_57600_RATE))), true, VLVT_UINT32,VLVD_NODIR|VLVF_PUB_RW|VLVF_DPI_CLAY,0,1 ,31,0);
        __Vscope_uart_tx.varInsert(__Vfinal,"CountWidth", const_cast<void*>(static_cast<const void*>(&(TOP.uart_tx__DOT__CountWidth))), true, VLVT_UINT32,VLVD_NODIR|VLVF_PUB_RW|VLVF_DPI_CLAY,0,1 ,31,0);
        __Vscope_uart_tx.varInsert(__Vfinal,"DataWidth", const_cast<void*>(static_cast<const void*>(&(TOP.uart_tx__DOT__DataWidth))), true, VLVT_UINT32,VLVD_NODIR|VLVF_PUB_RW|VLVF_DPI_CLAY,0,1 ,31,0);
        __Vscope_uart_tx.varInsert(__Vfinal,"busy_o", &(TOP.uart_tx__DOT__busy_o), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,0,0);
        __Vscope_uart_tx.varInsert(__Vfinal,"clk_i", &(TOP.uart_tx__DOT__clk_i), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,0,0);
        __Vscope_uart_tx.varInsert(__Vfinal,"count_reg", &(TOP.uart_tx__DOT__count_reg), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,0,1 ,2,0);
        __Vscope_uart_tx.varInsert(__Vfinal,"data_i", &(TOP.uart_tx__DOT__data_i), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,0,1 ,7,0);
        __Vscope_uart_tx.varInsert(__Vfinal,"dv_i", &(TOP.uart_tx__DOT__dv_i), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,0,0);
        __Vscope_uart_tx.varInsert(__Vfinal,"next_count", &(TOP.uart_tx__DOT__next_count), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,0,1 ,2,0);
        __Vscope_uart_tx.varInsert(__Vfinal,"next_sbuff", &(TOP.uart_tx__DOT__next_sbuff), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,0,1 ,7,0);
        __Vscope_uart_tx.varInsert(__Vfinal,"next_state", &(TOP.uart_tx__DOT__next_state), false, VLVT_UINT32,VLVD_NODIR|VLVF_PUB_RW|VLVF_DPI_CLAY,0,1 ,31,0);
        __Vscope_uart_tx.varInsert(__Vfinal,"rst_i", &(TOP.uart_tx__DOT__rst_i), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,0,0);
        __Vscope_uart_tx.varInsert(__Vfinal,"sbuff_empty", &(TOP.uart_tx__DOT__sbuff_empty), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,0,0);
        __Vscope_uart_tx.varInsert(__Vfinal,"sbuff_reg", &(TOP.uart_tx__DOT__sbuff_reg), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,0,1 ,7,0);
        __Vscope_uart_tx.varInsert(__Vfinal,"state_reg", &(TOP.uart_tx__DOT__state_reg), false, VLVT_UINT32,VLVD_NODIR|VLVF_PUB_RW|VLVF_DPI_CLAY,0,1 ,31,0);
        __Vscope_uart_tx.varInsert(__Vfinal,"tick_i", &(TOP.uart_tx__DOT__tick_i), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,0,0);
        __Vscope_uart_tx.varInsert(__Vfinal,"txd_o", &(TOP.uart_tx__DOT__txd_o), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,0,0);
    }
}
