# SPDX-FileCopyrightText: Copyright 2025 Vector Informatik GmbH
# SPDX-License-Identifier: MIT

add_executable(sil-kit-demo-byte-stream-socket-auto-sender SilKitDemoByteStreamSocketAutoSender.cpp)

target_link_libraries(sil-kit-demo-byte-stream-socket-auto-sender
    PRIVATE
        SilKit::SilKit
        sil-kit-adapters-common
)

set_target_properties(sil-kit-demo-byte-stream-socket-auto-sender
    PROPERTIES
        #ensure SilKit shared libraries can be loaded
        INSTALL_RPATH "$ORIGIN/../lib:$ORIGIN"
        BUILD_RPATH "$ORIGIN"
        RUNTIME_OUTPUT_DIRECTORY $<$<BOOL:ALWAYS>:${SILKIT_ADAPTER_BYTE_STREAM_SOCKET_OUTPUT_DIRECTORY}>
)
