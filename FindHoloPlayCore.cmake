# Download and extract Looking Glass Bridge SDK if not already present
set(LGBRIDGE_SDK_URL "https://github.com/xskere/LookingGlassVTKModule/releases/download/sdk.2.6.0.windows/LookingGlassBridge_SDK_2.6.0_Windows.zip")
set(LGBRIDGE_SDK_ZIP "${CMAKE_BINARY_DIR}/LookingGlassBridge_SDK_2.6.0_Windows.zip")
set(LGBRIDGE_SDK_DIR "${CMAKE_BINARY_DIR}/LookingGlassBridge_SDK_2.6.0_Windows")

if (NOT EXISTS "${LGBRIDGE_SDK_DIR}")
  message(STATUS "Downloading Looking Glass Bridge SDK from ${LGBRIDGE_SDK_URL}")
  file(DOWNLOAD "${LGBRIDGE_SDK_URL}" "${LGBRIDGE_SDK_ZIP}" SHOW_PROGRESS)
  message(STATUS "Extracting Looking Glass Bridge SDK...")
  file(MAKE_DIRECTORY "${LGBRIDGE_SDK_DIR}")
  execute_process(
    COMMAND ${CMAKE_COMMAND} -E tar xzf "${LGBRIDGE_SDK_ZIP}"
    WORKING_DIRECTORY "${LGBRIDGE_SDK_DIR}"
    RESULT_VARIABLE _extract_result
  )
  if (NOT _extract_result EQUAL 0)
    message(FATAL_ERROR "Failed to extract Looking Glass Bridge SDK zip file.")
  endif()
endif()

# Set paths to extracted files (assuming same structure as original program)
set(LookingGlassBridge_INCLUDE_DIR "${LGBRIDGE_SDK_DIR}/runtime")
set(LookingGlassBridge_LIBRARY "${LGBRIDGE_SDK_DIR}/bridge_inproc.lib")
set(LookingGlassBridge_DLL "${LGBRIDGE_SDK_DIR}/bridge_inproc.dll")

# No need to generate import library, just use the extracted files
set(LookingGlassBridge_HEADER_ONLY FALSE)
set(LookingGlassBridge_RUNTIME_LIBRARY "${LookingGlassBridge_DLL}")

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
