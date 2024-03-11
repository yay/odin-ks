package main

import "base:intrinsics"
import "base:runtime"
import win32 "core:sys/windows"

processor_core_count :: proc() -> int {
    length: win32.DWORD = 0
    result := win32.GetLogicalProcessorInformation(nil, &length)

    thread_count := 0
    if !result && win32.GetLastError() == 122 && length > 0 {
        runtime.DEFAULT_TEMP_ALLOCATOR_TEMP_GUARD()
        processors := make(
            []win32.SYSTEM_LOGICAL_PROCESSOR_INFORMATION,
            length,
            context.temp_allocator,
        )

        result = win32.GetLogicalProcessorInformation(&processors[0], &length)
        if result {
            for processor in processors {
                if processor.Relationship == .RelationProcessorCore {
                    thread := intrinsics.count_ones(processor.ProcessorMask)
                    thread_count += int(thread)
                }
            }
        }
    }

    return thread_count
}
