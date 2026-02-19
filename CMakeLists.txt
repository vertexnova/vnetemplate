#==============================================================================
# Copyright (c) 2026 Ajeet Singh Yadav. All rights reserved.
# Licensed under the Apache License, Version 2.0 (the "License")
#
# Author:    Ajeet Singh Yadav
# Created:   February 2026
#
# Autodoc:   yes
#==============================================================================

cmake_minimum_required(VERSION 3.16)
project(vnetemplate VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# CMake modules from vnecmake submodule (cmake/vnecmake)
set(VNE_DEPS_INTERNAL_DIR ${PROJECT_SOURCE_DIR}/deps/internal)
set(VNE_DEPS_EXTERNAL_DIR ${PROJECT_SOURCE_DIR}/deps/external)
set(VNECMAKE_MODULES "${PROJECT_SOURCE_DIR}/cmake/vnecmake/modules")
if(NOT EXISTS "${VNECMAKE_MODULES}/VneUseDep.cmake")
    message(FATAL_ERROR "vnecmake not found at cmake/vnecmake. Run: git submodule update --init --recursive")
endif()
list(APPEND CMAKE_MODULE_PATH "${VNECMAKE_MODULES}")

include(ProjectSetup)

#==============================================================================
# Platform Detection
#==============================================================================
if(DEFINED VNE_TARGET_PLATFORM)
    message(STATUS "Using manually specified target platform: ${VNE_TARGET_PLATFORM}")
else()
    if(EMSCRIPTEN)
        set(VNE_TARGET_PLATFORM "Web")
    elseif(WIN32)
        set(VNE_TARGET_PLATFORM "Windows")
    elseif(APPLE)
        if(VISIONOS OR ${CMAKE_SYSTEM_NAME} STREQUAL "visionOS")
            set(VNE_TARGET_PLATFORM "visionOS")
        elseif(IOS OR ${CMAKE_SYSTEM_NAME} STREQUAL "iOS")
            set(VNE_TARGET_PLATFORM "iOS")
        else()
            set(VNE_TARGET_PLATFORM "macOS")
        endif()
    elseif(UNIX)
        if(${CMAKE_SYSTEM_NAME} STREQUAL "Linux")
            set(VNE_TARGET_PLATFORM "Linux")
        elseif(${CMAKE_SYSTEM_NAME} STREQUAL "Android")
            set(VNE_TARGET_PLATFORM "Android")
        else()
            message(FATAL_ERROR "Unsupported UNIX platform: ${CMAKE_SYSTEM_NAME}")
        endif()
    else()
        message(FATAL_ERROR "Unsupported platform")
    endif()
endif()
message(STATUS "Detected platform: ${VNE_TARGET_PLATFORM}")

#==============================================================================
# Platform-specific compile definitions
#==============================================================================
if(VNE_TARGET_PLATFORM STREQUAL "macOS")
    add_compile_definitions(VNE_PLATFORM_MACOS)
elseif(VNE_TARGET_PLATFORM STREQUAL "iOS")
    add_compile_definitions(VNE_PLATFORM_IOS)
elseif(VNE_TARGET_PLATFORM STREQUAL "visionOS")
    add_compile_definitions(VNE_PLATFORM_VISIONOS)
elseif(VNE_TARGET_PLATFORM STREQUAL "Windows")
    add_compile_definitions(VNE_PLATFORM_WIN)
elseif(VNE_TARGET_PLATFORM STREQUAL "Linux")
    add_compile_definitions(VNE_PLATFORM_LINUX)
elseif(VNE_TARGET_PLATFORM STREQUAL "Android")
    add_compile_definitions(VNE_PLATFORM_ANDROID)
elseif(VNE_TARGET_PLATFORM STREQUAL "Web")
    add_compile_definitions(VNE_PLATFORM_WEB)
endif()

#==============================================================================
# Internal Libraries (deps/internal) - use if already in build, else add
#==============================================================================
include(VneUseDep)

function(_vnetemplate_configure_vnecommon_dep)
    get_property(_vt_build_examples_ty CACHE BUILD_EXAMPLES PROPERTY TYPE)
    if(NOT _vt_build_examples_ty STREQUAL "NOTFOUND" AND _vt_build_examples_ty)
        set(_vt_build_examples_saved "${BUILD_EXAMPLES}")
    endif()
    vne_use_dep(TARGET vne::common SUBDIR "${VNE_DEPS_INTERNAL_DIR}/vnecommon" BINARY_DIR "${CMAKE_BINARY_DIR}/deps/internal/vnecommon"
        CACHE_VARS BUILD_EXAMPLES OFF)
    if(DEFINED _vt_build_examples_saved)
        set(BUILD_EXAMPLES "${_vt_build_examples_saved}" CACHE BOOL "" FORCE)
    else()
        unset(BUILD_EXAMPLES CACHE)
    endif()
endfunction()
_vnetemplate_configure_vnecommon_dep()

function(_vnetemplate_configure_vnelogging_dep)
    get_property(_vt_build_tests_ty CACHE BUILD_TESTS PROPERTY TYPE)
    if(NOT _vt_build_tests_ty STREQUAL "NOTFOUND" AND _vt_build_tests_ty)
        set(_vt_build_tests_saved "${BUILD_TESTS}")
    endif()
    get_property(_vt_build_examples_ty CACHE BUILD_EXAMPLES PROPERTY TYPE)
    if(NOT _vt_build_examples_ty STREQUAL "NOTFOUND" AND _vt_build_examples_ty)
        set(_vt_build_examples_saved "${BUILD_EXAMPLES}")
    endif()
    set(BUILD_TESTS OFF CACHE BOOL "" FORCE)
    set(BUILD_EXAMPLES OFF CACHE BOOL "" FORCE)
    vne_use_dep(TARGET vne::logging SUBDIR "${VNE_DEPS_INTERNAL_DIR}/vnelogging" BINARY_DIR "${CMAKE_BINARY_DIR}/deps/internal/vnelogging"
        CACHE_VARS BUILD_TESTS OFF BUILD_EXAMPLES OFF)
    if(DEFINED _vt_build_tests_saved)
        set(BUILD_TESTS "${_vt_build_tests_saved}" CACHE BOOL "" FORCE)
    else()
        unset(BUILD_TESTS CACHE)
    endif()
    if(DEFINED _vt_build_examples_saved)
        set(BUILD_EXAMPLES "${_vt_build_examples_saved}" CACHE BOOL "" FORCE)
    else()
        unset(BUILD_EXAMPLES CACHE)
    endif()
endfunction()
_vnetemplate_configure_vnelogging_dep()

# Include dirs and config
set(VNE_INCLUDE_DIR ${PROJECT_SOURCE_DIR}/include)
set(VNE_SRC_DIR ${PROJECT_SOURCE_DIR}/src)
configure_file(${PROJECT_SOURCE_DIR}/configs/config.h.in ${CMAKE_BINARY_DIR}/config.h)
include_directories(${CMAKE_BINARY_DIR})

#==============================================================================
# Build Options
#==============================================================================
if(CMAKE_PROJECT_NAME STREQUAL "vnetemplate")
    set(VNE_TEMPLATE_DEV_DEFAULT ON)
else()
    set(VNE_TEMPLATE_DEV_DEFAULT OFF)
endif()
option(VNE_TEMPLATE_DEV "Dev build: enable tests (local development)" ${VNE_TEMPLATE_DEV_DEFAULT})
option(VNE_TEMPLATE_CI "CI build: enable tests (e.g. -DVNE_TEMPLATE_CI=ON in pipelines)" OFF)

if(VNE_TEMPLATE_CI)
    set(VNE_TEMPLATE_DEV OFF CACHE BOOL "" FORCE)
endif()

option(BUILD_TESTS "Build the test suite" ON)
option(VNE_TEMPLATE_TESTS "Build vnetemplate test suite (turn OFF when used as submodule)" ON)
option(BUILD_EXAMPLES "Build example programs" OFF)
option(ENABLE_DOXYGEN "Enable Doxygen documentation builds" OFF)

if(VNE_TEMPLATE_CI)
    set(BUILD_TESTS ON CACHE BOOL "" FORCE)
    set(VNE_TEMPLATE_TESTS ON CACHE BOOL "" FORCE)
    set(BUILD_EXAMPLES OFF CACHE BOOL "" FORCE)
    message(STATUS "VneTemplate: CI build -> BUILD_TESTS=ON, VNE_TEMPLATE_TESTS=ON, BUILD_EXAMPLES=OFF")
elseif(VNE_TEMPLATE_DEV)
    set(BUILD_TESTS ON CACHE BOOL "" FORCE)
    set(VNE_TEMPLATE_TESTS ON CACHE BOOL "" FORCE)
    set(BUILD_EXAMPLES ON CACHE BOOL "" FORCE)
    message(STATUS "VneTemplate: DEV build -> BUILD_TESTS=ON, VNE_TEMPLATE_TESTS=ON, BUILD_EXAMPLES=ON")
endif()

#==============================================================================
# Compiler Warnings
#==============================================================================
add_library(TemplateWarnings INTERFACE)
include(ProjectWarnings)
set_project_warnings(TemplateWarnings)
add_library(vne::template::Warnings ALIAS TemplateWarnings)

#==============================================================================
# Build Settings Interface Library
#==============================================================================
add_library(TemplateBuildSettings INTERFACE)
target_compile_features(TemplateBuildSettings INTERFACE cxx_std_20)
add_library(vne::template::BuildSettings ALIAS TemplateBuildSettings)

if(CMAKE_BUILD_TYPE MATCHES Debug)
    target_compile_definitions(TemplateBuildSettings INTERFACE VNE_BUILD_TYPE_DEBUG VNE_DEVELOPER_BUILD)
elseif(CMAKE_BUILD_TYPE MATCHES Release)
    target_compile_definitions(TemplateBuildSettings INTERFACE VNE_BUILD_TYPE_RELEASE)
elseif(CMAKE_BUILD_TYPE MATCHES RelWithDebInfo)
    target_compile_definitions(TemplateBuildSettings INTERFACE VNE_BUILD_TYPE_RELWITHDEBINFO)
elseif(CMAKE_BUILD_TYPE MATCHES MinSizeRel)
    target_compile_definitions(TemplateBuildSettings INTERFACE VNE_BUILD_TYPE_MINSIZEREL)
endif()

if(VNE_TARGET_PLATFORM STREQUAL "Windows")
    target_compile_definitions(TemplateBuildSettings INTERFACE VNE_PLATFORM_WIN)
elseif(VNE_TARGET_PLATFORM STREQUAL "Linux")
    target_compile_definitions(TemplateBuildSettings INTERFACE VNE_PLATFORM_LINUX)
elseif(VNE_TARGET_PLATFORM STREQUAL "macOS")
    target_compile_definitions(TemplateBuildSettings INTERFACE VNE_PLATFORM_MACOS)
elseif(VNE_TARGET_PLATFORM STREQUAL "iOS")
    target_compile_definitions(TemplateBuildSettings INTERFACE VNE_PLATFORM_IOS)
elseif(VNE_TARGET_PLATFORM STREQUAL "visionOS")
    target_compile_definitions(TemplateBuildSettings INTERFACE VNE_PLATFORM_VISIONOS)
elseif(VNE_TARGET_PLATFORM STREQUAL "Android")
    target_compile_definitions(TemplateBuildSettings INTERFACE VNE_PLATFORM_ANDROID)
elseif(VNE_TARGET_PLATFORM STREQUAL "Web")
    target_compile_definitions(TemplateBuildSettings INTERFACE VNE_PLATFORM_WEB)
endif()

#==============================================================================
# Add Library
#==============================================================================
add_subdirectory(src)

#==============================================================================
# Tests
#==============================================================================
if(BUILD_TESTS AND VNE_TEMPLATE_TESTS)
    enable_testing()
    add_subdirectory(tests)
endif()

#==============================================================================
# Examples
#==============================================================================
if(BUILD_EXAMPLES)
    add_subdirectory(examples)
endif()

#==============================================================================
# Documentation
#==============================================================================
if(ENABLE_DOXYGEN)
    find_package(Doxygen QUIET OPTIONAL_COMPONENTS dot)
    if(Doxygen_FOUND)
        set(DOXYGEN_IN ${PROJECT_SOURCE_DIR}/docs/doxyfile.in)
        set(DOXYGEN_OUT ${CMAKE_BINARY_DIR}/doxyfile)
        set(DOXYGEN_HAVE_DOT ${DOXYGEN_DOT_FOUND})
        configure_file(${DOXYGEN_IN} ${DOXYGEN_OUT} @ONLY)
        add_custom_target(vnetemplate_doc_doxygen ALL
            COMMAND ${DOXYGEN_EXECUTABLE} ${DOXYGEN_OUT}
            WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
            COMMENT "Generating API documentation with Doxygen"
            VERBATIM
        )
        message(STATUS "Doxygen target: vnetemplate_doc_doxygen")
    else()
        message(STATUS "Doxygen not found. Install doxygen to build documentation.")
    endif()
endif()

#==============================================================================
# Installation
#==============================================================================
include(GNUInstallDirs)
install(TARGETS vnetemplate TemplateWarnings TemplateBuildSettings
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    INCLUDES DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
)
install(DIRECTORY include/vertexnova/ DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/vertexnova FILES_MATCHING PATTERN "*.h")
install(DIRECTORY src/vertexnova/ DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/vertexnova FILES_MATCHING PATTERN "*.h")
install(FILES ${CMAKE_BINARY_DIR}/config.h DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/vertexnova/template)
