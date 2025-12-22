# FindHoloPlayCore.cmake - Find Looking Glass Bridge SDK
# This module finds the Looking Glass Bridge SDK headers and libraries
# For backward compatibility, this file is named FindHoloPlayCore.cmake but uses LookingGlassBridge variables
#
# On Windows with Bridge SDK 2.6+, we can use the DLL directly without an import library

# Find the Bridge SDK headers
find_path(LookingGlassBridge_INCLUDE_DIR
  NAMES bridge.h
  HINTS
    # Windows installation path for Bridge SDK
    "C:/Program Files/Looking Glass/Looking Glass Bridge 2.6.0/runtime"
    # macOS installation path for Bridge SDK
    "/Applications/Looking Glass Bridge 2.6.0.app/Contents/runtime"
  DOC "Looking Glass Bridge SDK include directory")

# Try to find import library
find_library(LookingGlassBridge_LIBRARY
  NAMES bridge bridge_inproc
  HINTS
    # Windows installation path for Bridge SDK
    "C:/Program Files/Looking Glass/Looking Glass Bridge 2.6.0"
    "C:/Program Files/Looking Glass/Looking Glass Bridge 2.6.0/lib"
    "C:/Program Files/Looking Glass/Looking Glass Bridge 2.6.0/runtime"
    # macOS installation path for Bridge SDK
    "/Applications/Looking Glass Bridge 2.6.0.app/Contents/MacOS"
  DOC "Looking Glass Bridge SDK library")

# Find the runtime DLL (required on Windows when no .lib is available)
if (WIN32)
  find_file(LookingGlassBridge_DLL
    NAMES bridge_inproc.dll
    HINTS
      "C:/Program Files/Looking Glass/Looking Glass Bridge 2.6.0"
    DOC "Looking Glass Bridge SDK runtime DLL")
endif()

# On Windows with Bridge SDK 2.6+, generate import library from .def file
set(LookingGlassBridge_HEADER_ONLY FALSE)
if (WIN32 AND LookingGlassBridge_INCLUDE_DIR AND LookingGlassBridge_DLL AND NOT LookingGlassBridge_LIBRARY)
  message(STATUS "Found Bridge SDK headers and DLL - generating import library")
  set(LookingGlassBridge_HEADER_ONLY TRUE)

  # Locate the .def file and set up paths
  get_filename_component(MODULE_DIR "${CMAKE_CURRENT_LIST_FILE}" DIRECTORY)
  set(DEF_FILE "${MODULE_DIR}/bridge_exports.def")
  set(LookingGlassBridge_GENERATED_LIB "${CMAKE_CURRENT_BINARY_DIR}/bridge_inproc.lib")

  # Find lib.exe
  find_program(LIB_EXECUTABLE lib)

  if (LIB_EXECUTABLE AND EXISTS "${DEF_FILE}")
    if (NOT EXISTS "${LookingGlassBridge_GENERATED_LIB}")
      message(STATUS "Generating import library from ${DEF_FILE}")
      # Use file(TO_NATIVE_PATH) to get proper Windows paths without extra quotes
      file(TO_NATIVE_PATH "${DEF_FILE}" DEF_FILE_NATIVE)
      file(TO_NATIVE_PATH "${LookingGlassBridge_GENERATED_LIB}" LIB_FILE_NATIVE)

      execute_process(
        COMMAND ${LIB_EXECUTABLE} /DEF:${DEF_FILE_NATIVE} /OUT:${LIB_FILE_NATIVE} /MACHINE:X64
        WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}"
        RESULT_VARIABLE LIB_RESULT
        OUTPUT_VARIABLE LIB_OUTPUT
        ERROR_VARIABLE LIB_ERROR
      )

      if (LIB_RESULT EQUAL 0 AND EXISTS "${LookingGlassBridge_GENERATED_LIB}")
        message(STATUS "Successfully generated: ${LookingGlassBridge_GENERATED_LIB}")
        set(LookingGlassBridge_LIBRARY "${LookingGlassBridge_GENERATED_LIB}")
      else()
        message(WARNING "Failed to generate import library (code: ${LIB_RESULT})\n${LIB_OUTPUT}\n${LIB_ERROR}")
      endif()
    else()
      message(STATUS "Using existing import library: ${LookingGlassBridge_GENERATED_LIB}")
      set(LookingGlassBridge_LIBRARY "${LookingGlassBridge_GENERATED_LIB}")
    endif()
  else()
    if (NOT LIB_EXECUTABLE)
      message(WARNING "lib.exe not found")
    endif()
    if (NOT EXISTS "${DEF_FILE}")
      message(WARNING "DEF file not found: ${DEF_FILE}")
    endif()
  endif()

  # Fail if we still don't have a library
  if (NOT LookingGlassBridge_LIBRARY OR NOT EXISTS "${LookingGlassBridge_LIBRARY}")
    message(FATAL_ERROR "Could not generate import library. Please manually run:\n"
      "  lib /DEF:${DEF_FILE} /OUT:${LookingGlassBridge_GENERATED_LIB} /MACHINE:X64")
  endif()

  set(LookingGlassBridge_RUNTIME_LIBRARY "${LookingGlassBridge_DLL}")
endif()

include(FindPackageHandleStandardArgs)
if (LookingGlassBridge_HEADER_ONLY)
  find_package_handle_standard_args(HoloPlayCore
    REQUIRED_VARS LookingGlassBridge_DLL LookingGlassBridge_INCLUDE_DIR
  )
else()
  find_package_handle_standard_args(HoloPlayCore
    REQUIRED_VARS LookingGlassBridge_LIBRARY LookingGlassBridge_INCLUDE_DIR
  )
endif()

if (HoloPlayCore_FOUND)
  if (NOT LookingGlassBridge_RUNTIME_LIBRARY)
    if (WIN32)
      if (LookingGlassBridge_DLL)
        set(LookingGlassBridge_RUNTIME_LIBRARY "${LookingGlassBridge_DLL}")
      else()
        # It should be next to the library
        get_filename_component(_dir ${LookingGlassBridge_LIBRARY} DIRECTORY)
        set(LookingGlassBridge_RUNTIME_LIBRARY "${_dir}/bridge_inproc.dll")
      endif()
    else ()
      # On Linux and Mac, it is the same as the library
      set(LookingGlassBridge_RUNTIME_LIBRARY "${LookingGlassBridge_LIBRARY}")
    endif ()
  endif ()

  set(LookingGlassBridge_INCLUDE_DIRS "${LookingGlassBridge_INCLUDE_DIR}")
  set(LookingGlassBridge_LIBRARIES "${LookingGlassBridge_LIBRARY}")

  # For backward compatibility, also set HoloPlayCore variables
  set(HoloPlayCore_INCLUDE_DIR "${LookingGlassBridge_INCLUDE_DIR}")
  set(HoloPlayCore_LIBRARY "${LookingGlassBridge_LIBRARY}")
  set(HoloPlayCore_RUNTIME_LIBRARY "${LookingGlassBridge_RUNTIME_LIBRARY}")
  set(HoloPlayCore_INCLUDE_DIRS "${LookingGlassBridge_INCLUDE_DIRS}")
  set(HoloPlayCore_LIBRARIES "${LookingGlassBridge_LIBRARIES}")

  mark_as_advanced(LookingGlassBridge_INCLUDE_DIR)
  mark_as_advanced(LookingGlassBridge_LIBRARY)
  mark_as_advanced(LookingGlassBridge_RUNTIME_LIBRARY)
  mark_as_advanced(HoloPlayCore_INCLUDE_DIR)
  mark_as_advanced(HoloPlayCore_LIBRARY)
  mark_as_advanced(HoloPlayCore_RUNTIME_LIBRARY)
  if (WIN32)
    mark_as_advanced(LookingGlassBridge_DLL)
  endif()

  if (NOT TARGET HoloPlayCore::HoloPlayCore)
    # Create a library target - use UNKNOWN IMPORTED since we now have a .lib file
    add_library(HoloPlayCore::HoloPlayCore UNKNOWN IMPORTED)
    set_target_properties(HoloPlayCore::HoloPlayCore
      PROPERTIES
        IMPORTED_LOCATION "${LookingGlassBridge_LIBRARY}"
        INTERFACE_INCLUDE_DIRECTORIES "${LookingGlassBridge_INCLUDE_DIR}")
  endif ()

  message(STATUS "Looking Glass Bridge SDK found:")
  message(STATUS "  Include: ${LookingGlassBridge_INCLUDE_DIR}")
  message(STATUS "  Library: ${LookingGlassBridge_LIBRARY}")
  message(STATUS "  Runtime: ${LookingGlassBridge_RUNTIME_LIBRARY}")
  if (LookingGlassBridge_HEADER_ONLY)
    message(STATUS "  Mode: Header-only (using DLL directly)")
  endif()
endif ()
