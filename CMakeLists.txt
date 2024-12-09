cmake_minimum_required( VERSION 3.12 )
project( VectorSilKitAdapterByteStreamSocket )

set( SILKIT_ADAPTER_BYTE_STREAM_SOCKET_OUTPUT_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/bin" )
set( SILKIT_ADAPTER_BYTE_STREAM_SOCKET_LIBRARY_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/lib" )

set( SILKIT_ADAPTER_BYTE_STREAM_SOCKET_VERSION "1.0.0" )

include( common/cmake/RepoTargets.cmake )

build_common_demo( 
  common/demos/SilKitDemoBytesPubSubEchoDevice.cpp
  sil-kit-demo-byte-stream-echo-device
  ${SILKIT_ADAPTER_BYTE_STREAM_SOCKET_OUTPUT_DIRECTORY}
)

add_subdirectory( adapter )

include( common/cmake/InstallFunctions.cmake )

fix_windows_install_folder( ${SILKIT_ADAPTER_BYTE_STREAM_SOCKET_VERSION} )

install_adapter_source( ${CMAKE_CURRENT_SOURCE_DIR}/adapter )
install_git_source( ${CMAKE_CURRENT_SOURCE_DIR}/common )
install_root_source_files()

install_silkit_lib(
    ${SILKIT_ADAPTER_BYTE_STREAM_SOCKET_OUTPUT_DIRECTORY}
    ${SILKIT_ADAPTER_BYTE_STREAM_SOCKET_LIBRARY_DIRECTORY}
)

install_demo( sil-kit-demo-byte-stream-echo-device )

install_adapter( sil-kit-adapter-byte-stream-socket )

include( common/cmake/Packaging.cmake )

declare_package(
  "SilKit-Adapter-Byte-Stream-Socket"
  "binary release of SIL Kit Adapter Byte Stream Socket"
)
