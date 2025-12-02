# SPDX-FileCopyrightText: Copyright 2025 Vector Informatik GmbH
# SPDX-License-Identifier: MIT

cmake_minimum_required(VERSION 3.13)
project(VectorSilKitAdapterByteStreamSocket)

set(SILKIT_ADAPTER_BYTE_STREAM_SOCKET_OUTPUT_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/bin")
set(SILKIT_ADAPTER_BYTE_STREAM_SOCKET_LIBRARY_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/lib")

include(common/cmake/RepoTargets.cmake)

include(${CMAKE_CURRENT_LIST_DIR}/cmake/SilKitAdapterVersion.cmake)
configure_silkit_adapter_version(${PROJECT_NAME})

add_subdirectory(adapter)
add_subdirectory(demos)

include(common/cmake/InstallFunctions.cmake)

fix_windows_install_folder("SIL Kit Adapter for Byte Stream Socket" ${PROJECT_VERSION} )

install_adapter_source(
    ${CMAKE_CURRENT_SOURCE_DIR}/adapter
    ${CMAKE_CURRENT_SOURCE_DIR}/cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/demos
    ${CMAKE_CURRENT_SOURCE_DIR}/tools
)
install_git_source(${CMAKE_CURRENT_SOURCE_DIR}/common)
install_root_source_files()

install_silkit_lib(
    ${SILKIT_ADAPTER_BYTE_STREAM_SOCKET_OUTPUT_DIRECTORY}
    ${SILKIT_ADAPTER_BYTE_STREAM_SOCKET_LIBRARY_DIRECTORY}
)

install_adapter(sil-kit-adapter-byte-stream-socket)
install_demo(sil-kit-demo-byte-stream-socket-auto-sender)

include(common/cmake/Packaging.cmake)

install_scripts_to(demos/CANoe4SW_SE
    ${CMAKE_CURRENT_SOURCE_DIR}/demos/CANoe4SW_SE/run.sh
    ${CMAKE_CURRENT_SOURCE_DIR}/demos/CANoe4SW_SE/run_all.sh
    ${CMAKE_CURRENT_SOURCE_DIR}/demos/CANoe4SW_SE/createEnvironment.sh
)

install_scripts_to(tools
    ${CMAKE_CURRENT_SOURCE_DIR}/tools/echo_server.sh
)

if(NOT DEFINED PACKAGE_FILENAME_SUFFIX)
    set(PACKAGE_FILENAME_SUFFIX "-${PROJECT_VERSION}")
endif()

declare_package(
    "SilKit-Adapter-Byte-Stream-Socket"
    "binary release of SIL Kit Adapter Byte Stream Socket"
)