
add_executable( sil-kit-adapter-byte-stream-socket
    "SilKitAdapterByteStreamSocket.cpp"
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

include( ${CMAKE_CURRENT_LIST_DIR}/../common/cmake/Building.cmake )

copy_sil_kit_to_bin(
  sil-kit-adapter-byte-stream-socket
  ${SILKIT_ADAPTER_BYTE_STREAM_SOCKET_OUTPUT_DIRECTORY}
  ${SILKIT_ADAPTER_BYTE_STREAM_SOCKET_LIBRARY_DIRECTORY}
)
