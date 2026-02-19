message(STATUS "LookingGlass: Building as a Remote VTK module")

list (APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR})

set(classes
  vtkLookingGlassInterface
  vtkLookingGlassPass
)

# add OS specic render window implementation
if (VTK_USE_X)
  list(APPEND classes vtkXLookingGlassRenderWindow)
elseif (WIN32)
  list(APPEND classes vtkWin32LookingGlassRenderWindow)
elseif (VTK_USE_COCOA)
  list(APPEND sources vtkCocoaLookingGlassRenderWindow.mm)
  list(APPEND headers vtkCocoaLookingGlassRenderWindow.h)
endif()


vtk_module_add_module(VTK::RenderingLookingGlass
  CLASSES ${classes}
  SOURCES ${sources}
  HEADERS ${headers}
)

if (NOT HoloPlayCore_INCLUDE_DIR OR NOT HoloPlayCore_LIBRARY)
  # Download HoloPlayCore if it is not set already
  include(FetchHoloPlayCore)
endif()

vtk_module_find_package(PACKAGE HoloPlayCore)
vtk_module_link(VTK::RenderingLookingGlass
    PUBLIC HoloPlayCore::HoloPlayCore)
if (APPLE)
  vtk_module_link(VTK::RenderingLookingGlass
    PRIVATE "-framework IOKit")
endif ()

# Copy the FindHoloPlayCore.cmake file to the build directory
if (DEFINED vtk_cmake_build_dir)
  configure_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/FindHoloPlayCore.cmake"
    "${vtk_cmake_build_dir}/FindHoloPlayCore.cmake"
    COPYONLY)
endif ()

# Workaround limitation of VTK build-system preventing export module specific CMake variables
# in module config files.
if (DEFINED vtk_cmake_destination AND VTK_BINARY_DIR)
  configure_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/FindHoloPlayCore.cmake"
    "${VTK_BINARY_DIR}/${vtk_cmake_destination}/FindHoloPlayCore.cmake"
    COPYONLY)
endif ()

if (DEFINED vtk_cmake_destination)
  install(
    FILES "${CMAKE_CURRENT_SOURCE_DIR}/FindHoloPlayCore.cmake"
    DESTINATION "${vtk_cmake_destination}"
    COMPONENT   "development")
endif ()

if (VTK_WHEEL_BUILD)
  # Need to install the HoloPlayCore_RUNTIME_LIBRARY
  # FIXME: can we find a way to NOT set the DESTINATION manually?
  install(
    FILES "${HoloPlayCore_RUNTIME_LIBRARY}"
    DESTINATION "${CMAKE_INSTALL_LIBDIR}/vtkmodules")
else()
  # For regular installs (CPack, Slicer extensions, etc.) install the runtime
  # library to the standard platform location so packagers pick it up.
  if (WIN32)
    set(_runtime_dest "${CMAKE_INSTALL_BINDIR}")
    # Install all DLLs from the SDK directory, not just the primary one
    get_filename_component(_bridge_sdk_dir "${HoloPlayCore_RUNTIME_LIBRARY}" DIRECTORY)
    file(GLOB _bridge_runtime_files "${_bridge_sdk_dir}/*.dll")
  else()
    set(_runtime_dest "${CMAKE_INSTALL_LIBDIR}")
    set(_bridge_runtime_files "${HoloPlayCore_RUNTIME_LIBRARY}")
  endif()
  install(
    FILES ${_bridge_runtime_files}
    DESTINATION "${_runtime_dest}"
    COMPONENT "runtime")
endif()
