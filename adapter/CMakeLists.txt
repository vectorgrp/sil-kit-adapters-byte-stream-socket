
add_executable( sil-kit-adapter-byte-stream-socket
    "SilKitAdapterByteStreamSocket.cpp"
)

target_include_directories( sil-kit-adapter-byte-stream-socket 
    PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}
)

target_link_libraries( sil-kit-adapter-byte-stream-socket
    PRIVATE
        asio
        SilKit::SilKit
        sil-kit-adapters-common
)

set_target_properties( sil-kit-adapter-byte-stream-socket 
	PROPERTIES
    #ensure SilKit shared libraries can be loaded
    INSTALL_RPATH "$ORIGIN/../lib:$ORIGIN"
    BUILD_RPATH "$ORIGIN"
    RUNTIME_OUTPUT_DIRECTORY $<$<BOOL:ALWAYS>:${SILKIT_ADAPTER_BYTE_STREAM_SOCKET_OUTPUT_DIRECTORY}>
)

add_custom_command( TARGET sil-kit-adapter-byte-stream-socket POST_BUILD
    COMMAND ${CMAKE_COMMAND}
    ARGS -E copy $<TARGET_FILE:SilKit::SilKit> ${SILKIT_ADAPTER_BYTE_STREAM_SOCKET_LIBRARY_DIRECTORY}/libSilKit.so
)