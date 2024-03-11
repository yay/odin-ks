package main

import "core:sys/darwin"

CTL_HW :: 6 // generic cpu/io
HW_NCPU :: 3 // number of cpus

processor_core_count :: proc() -> int {
    mib := [2]i32{CTL_HW, HW_NCPU}
    out := u32(0)
    nout := i64(size_of(out))
    ret := darwin.syscall_sysctl(&mib[0], 2, &out, &nout, nil, 0)
    if ret >= 0 && int(out) > 0 {
        return int(out)
    }
    return 1
}
