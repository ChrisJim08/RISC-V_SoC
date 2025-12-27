// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Symbol table implementation internals

#include "Vtop__pch.h"
#include "Vtop.h"
#include "Vtop___024root.h"

// FUNCTIONS
Vtop__Syms::~Vtop__Syms()
{

    // Tear down scope hierarchy
    __Vhier.remove(0, &__Vscope_fifo);

}

Vtop__Syms::Vtop__Syms(VerilatedContext* contextp, const char* namep, Vtop* modelp)
    : VerilatedSyms{contextp}
    // Setup internal state of the Syms class
    , __Vm_modelp{modelp}
    // Setup module instances
    , TOP{this, namep}
{
        // Check resources
        Verilated::stackCheck(41);
    // Configure time unit / time precision
    _vm_contextp__->timeunit(-9);
    _vm_contextp__->timeprecision(-12);
    // Setup each module's pointers to their submodules
    // Setup each module's pointer back to symbol table (for public functions)
    TOP.__Vconfigure(true);
    // Setup scopes
    __Vscope_TOP.configure(this, name(), "TOP", "TOP", "<null>", 0, VerilatedScope::SCOPE_OTHER);
    __Vscope_fifo.configure(this, name(), "fifo", "fifo", "fifo", -9, VerilatedScope::SCOPE_MODULE);

    // Set up scope hierarchy
    __Vhier.add(0, &__Vscope_fifo);

    // Setup export functions
    for (int __Vfinal = 0; __Vfinal < 2; ++__Vfinal) {
        __Vscope_TOP.varInsert(__Vfinal,"clk_i", &(TOP.clk_i), false, VLVT_UINT8,VLVD_IN|VLVF_PUB_RW,0,0);
        __Vscope_TOP.varInsert(__Vfinal,"empty_o", &(TOP.empty_o), false, VLVT_UINT8,VLVD_OUT|VLVF_PUB_RW,0,0);
        __Vscope_TOP.varInsert(__Vfinal,"full_o", &(TOP.full_o), false, VLVT_UINT8,VLVD_OUT|VLVF_PUB_RW,0,0);
        __Vscope_TOP.varInsert(__Vfinal,"rd_data_o", &(TOP.rd_data_o), false, VLVT_UINT32,VLVD_OUT|VLVF_PUB_RW,0,1 ,31,0);
        __Vscope_TOP.varInsert(__Vfinal,"rd_en_i", &(TOP.rd_en_i), false, VLVT_UINT8,VLVD_IN|VLVF_PUB_RW,0,0);
        __Vscope_TOP.varInsert(__Vfinal,"rst_i", &(TOP.rst_i), false, VLVT_UINT8,VLVD_IN|VLVF_PUB_RW,0,0);
        __Vscope_TOP.varInsert(__Vfinal,"wr_data_i", &(TOP.wr_data_i), false, VLVT_UINT32,VLVD_IN|VLVF_PUB_RW,0,1 ,31,0);
        __Vscope_TOP.varInsert(__Vfinal,"wr_en_i", &(TOP.wr_en_i), false, VLVT_UINT8,VLVD_IN|VLVF_PUB_RW,0,0);
        __Vscope_fifo.varInsert(__Vfinal,"DataWidth", const_cast<void*>(static_cast<const void*>(&(TOP.fifo__DOT__DataWidth))), true, VLVT_UINT32,VLVD_NODIR|VLVF_PUB_RW|VLVF_DPI_CLAY,0,1 ,31,0);
        __Vscope_fifo.varInsert(__Vfinal,"Depth", const_cast<void*>(static_cast<const void*>(&(TOP.fifo__DOT__Depth))), true, VLVT_UINT32,VLVD_NODIR|VLVF_PUB_RW|VLVF_DPI_CLAY,0,1 ,31,0);
        __Vscope_fifo.varInsert(__Vfinal,"PointerWidth", const_cast<void*>(static_cast<const void*>(&(TOP.fifo__DOT__PointerWidth))), true, VLVT_UINT32,VLVD_NODIR|VLVF_PUB_RW|VLVF_DPI_CLAY,0,1 ,31,0);
        __Vscope_fifo.varInsert(__Vfinal,"clk_i", &(TOP.fifo__DOT__clk_i), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,0,0);
        __Vscope_fifo.varInsert(__Vfinal,"empty_o", &(TOP.fifo__DOT__empty_o), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,0,0);
        __Vscope_fifo.varInsert(__Vfinal,"full_o", &(TOP.fifo__DOT__full_o), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,0,0);
        __Vscope_fifo.varInsert(__Vfinal,"mem", &(TOP.fifo__DOT__mem), false, VLVT_UINT32,VLVD_NODIR|VLVF_PUB_RW,1,1 ,15,0 ,31,0);
        __Vscope_fifo.varInsert(__Vfinal,"rd_data_o", &(TOP.fifo__DOT__rd_data_o), false, VLVT_UINT32,VLVD_NODIR|VLVF_PUB_RW,0,1 ,31,0);
        __Vscope_fifo.varInsert(__Vfinal,"rd_en_i", &(TOP.fifo__DOT__rd_en_i), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,0,0);
        __Vscope_fifo.varInsert(__Vfinal,"rd_ptr", &(TOP.fifo__DOT__rd_ptr), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,0,1 ,4,0);
        __Vscope_fifo.varInsert(__Vfinal,"rd_valid", &(TOP.fifo__DOT__rd_valid), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,0,0);
        __Vscope_fifo.varInsert(__Vfinal,"rst_i", &(TOP.fifo__DOT__rst_i), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,0,0);
        __Vscope_fifo.varInsert(__Vfinal,"wr_data_i", &(TOP.fifo__DOT__wr_data_i), false, VLVT_UINT32,VLVD_NODIR|VLVF_PUB_RW,0,1 ,31,0);
        __Vscope_fifo.varInsert(__Vfinal,"wr_en_i", &(TOP.fifo__DOT__wr_en_i), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,0,0);
        __Vscope_fifo.varInsert(__Vfinal,"wr_ptr", &(TOP.fifo__DOT__wr_ptr), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,0,1 ,4,0);
        __Vscope_fifo.varInsert(__Vfinal,"wr_valid", &(TOP.fifo__DOT__wr_valid), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,0,0);
    }
}
