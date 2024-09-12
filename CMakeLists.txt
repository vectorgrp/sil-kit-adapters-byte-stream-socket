cmake_minimum_required( VERSION 3.12 )
project( VectorSilKitAdapterByteStreamSocket )

set( SILKIT_ADAPTER_BYTE_STREAM_SOCKET_OUTPUT_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/bin" )
set( SILKIT_ADAPTER_BYTE_STREAM_SOCKET_LIBRARY_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/lib" )
set( SILKIT_ADAPTERS_DEMOS_OUTPUT_DIRECTORY "${SILKIT_ADAPTER_BYTE_STREAM_SOCKET_OUTPUT_DIRECTORY}" )

set( SILKIT_ADAPTER_BYTE_STREAM_SOCKET_VERSION "1.0.0" )

set( COMMON_DEMOS_TO_BUILD SilKitDemoBytesPubSubEchoDevice )
include( common/cmake/CMakeLists.txt )
set_target_properties( SilKitDemoBytesPubSubEchoDevice PROPERTIES OUTPUT_NAME "sil-kit-demo-byte-stream-echo-device" )

add_subdirectory( adapter )

################################################################################
# Distribution of the source code and binaries
################################################################################
# Install sources and binaries
# Copy all files from the source and bin directory to the proper destination
# Leave out git repo related data

if( WIN32 )
    if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
        # set the default install paths for Windows 32 and 64 bits
        if( CMAKE_SIZEOF_VOID_P EQUAL 8 )
            set( CMAKE_INSTALL_PREFIX "C:/Program Files/Vector SIL Kit Adapter Bytestream Socket ${SILKIT_ADAPTER_BYTE_STREAM_SOCKET_VERSION}" CACHE PATH "Default install path" FORCE )
        elseif( CMAKE_SIZEOF_VOID_P EQUAL 4 )
            set( CMAKE_INSTALL_PREFIX "C:/Program Files (x86)/Vector SIL Kit Adapter Bytestream Socket ${SILKIT_ADAPTER_BYTE_STREAM_SOCKET_VERSION}" CACHE PATH "Default install path" FORCE )
        endif()
    endif(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
endif()

install(
    DIRECTORY
        ${CMAKE_CURRENT_SOURCE_DIR}/adapter
        ${CMAKE_CURRENT_SOURCE_DIR}/common

    DESTINATION .
    COMPONENT source
    EXCLUDE_FROM_ALL
    REGEX "\.git$" EXCLUDE
    REGEX "\.github$" EXCLUDE
    REGEX "Downloads$" EXCLUDE
)

install(
    FILES
        CMakeLists.txt
        CMakePresets.json
        LICENSE
        README.md
        SECURITY.md
        CONTRIBUTING.md
    DESTINATION .
    COMPONENT source
    EXCLUDE_FROM_ALL
)

include( GNUInstallDirs )

if(WIN32)
    install(
        FILES
            ${SILKIT_ADAPTER_BYTE_STREAM_SOCKET_OUTPUT_DIRECTORY}/SilKit.dll
        DESTINATION ${CMAKE_INSTALL_BINDIR}
        COMPONENT lib
        EXCLUDE_FROM_ALL
    )
    install(
        FILES
            ${SILKIT_ADAPTER_BYTE_STREAM_SOCKET_LIBRARY_DIRECTORY}/SilKit.lib
        DESTINATION ${CMAKE_INSTALL_LIBDIR}
        COMPONENT lib
        EXCLUDE_FROM_ALL
    )
else()
    install(
        FILES
            ${SILKIT_ADAPTER_BYTE_STREAM_SOCKET_LIBRARY_DIRECTORY}/libSilKit.so
        DESTINATION ${CMAKE_INSTALL_LIBDIR}
        PERMISSIONS
            OWNER_READ OWNER_WRITE
            GROUP_READ
            WORLD_READ
        COMPONENT lib
        EXCLUDE_FROM_ALL
    )
endif()

install(
    TARGETS 
        SilKitDemoBytesPubSubEchoDevice
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR} COMPONENT Runtime
    PERMISSIONS
        OWNER_READ OWNER_WRITE OWNER_EXECUTE
        GROUP_READ GROUP_EXECUTE
        WORLD_READ WORLD_EXECUTE    
    EXCLUDE_FROM_ALL
)

# only sil-kit-adapter-byte-stream-socket should be installed to /usr/local/bin by calling --target install (therefore it is not excluded)
install(
    TARGETS 
        sil-kit-adapter-byte-stream-socket
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR} COMPONENT Runtime
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR} COMPONENT Runtime
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}/sil-kit-adapter-byte-stream-socket COMPONENT Development
    PERMISSIONS
        OWNER_READ OWNER_WRITE OWNER_EXECUTE
        GROUP_READ GROUP_EXECUTE
        WORLD_READ WORLD_EXECUTE
)

###############################################################################
# Packaging
###############################################################################

set( CPACK_GENERATOR           "ZIP" )

set( CPACK_PACKAGE_DESCRIPTION "binary release of SIL Kit Adapter Byte Stream Socket" )
set( CPACK_PACKAGE_NAME        "SilKit-Adapter-Byte-Stream-Socket" )
set( CPACK_PACKAGE_VENDOR      "Vector Informatik" )
set( CPACK_PACKAGE_CONTACT     "support@vector.com" )
set( CPACK_PACKAGE_FILE_NAME   "${CPACK_PACKAGE_NAME}${PACKAGE_FILENAME_SUFFIX}" )

set( CPACK_ARCHIVE_COMPONENT_INSTALL            ON )
set( CPACK_COMPONENTS_ALL_IN_ONE_PACKAGE        ON )
set( CPACK_COMPONENT_INCLUDE_TOPLEVEL_DIRECTORY ON )

include( CPack )
