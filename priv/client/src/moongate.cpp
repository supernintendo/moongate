#include <emscripten/bind.h>
#include <emscripten.h>
#include <cstdio>
#include "moongate.h"

Moongate::Moongate(void) {}
void Moongate::connected() {}
void Moongate::receive() {}
void Moongate::up() {
    #ifdef EMSCRIPTEN
        EM_ASM(Moongate.Firmware.up());
    #endif
}

EMSCRIPTEN_BINDINGS(external_constructors) {
    emscripten::class_<Moongate>("Moongate")
        .constructor<>()
        .function("connected", &Moongate::connected)
        .function("receive", &Moongate::receive)
        .function("up", &Moongate::up)
    ;
}
