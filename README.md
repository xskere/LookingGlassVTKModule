# Looking Glass Device Support

## Introduction

The LookingGlassVTKModule provides support for rendering VTK scenes into
looking glass devices. Both Python bindings (via the
[`vtk-lookingglass` package on pip](https://pypi.org/project/vtk-lookingglass/))
and C++ builds are supported.

## Python Support
The simplest way to get started is by running `pip install vtk-lookingglass`
and then trying out examples in the `Examples/Python` directory. This should
work on all major operating systems, and for most modern versions of Python.

In fact, many [VTK Python Examples](https://kitware.github.io/vtk-examples/site/Python/) can be easily adapted
to render to the Looking Glass render window by simply swapping out the
example's render window with one created via
`vtkLookingGlassInterface.CreateLookingGlassRenderWindow()`.

## C++ Support
For C++ support, there are two main approaches.
You can create a OS specific Looking Glass render window and use it as you
would a regular vtkRenderWindow. For an example of this approach please see
the TestDragon test in `Testing/Cxx/TestDragon.cxx`. The other approach is to
use the vtkLookingGlassPass as you would normally use a render pass in a
renderer. For an example of that approach please see
`Testing\Cxx\TestLookingGlassPass.cxx`.

### Build Requirements

**Important: This module now uses the Looking Glass Bridge SDK (v2.4+), which replaces the legacy HoloPlayCore SDK.**

Building this module requires the Looking Glass Bridge SDK, which is automatically installed
when you install [Looking Glass Bridge](https://lookingglassfactory.com/software/looking-glass-bridge)
(version 2.4.10 or later). The Bridge SDK provides support for all modern Looking Glass displays
including the 16", 32", and 65" Light Field displays released after 2022.

#### Installing Looking Glass Bridge

1. Download and install Looking Glass Bridge from [lookingglassfactory.com](https://lookingglassfactory.com/software/looking-glass-bridge)
2. The Bridge SDK headers and libraries are automatically installed:
   - **Windows**: `C:\Program Files\Looking Glass\Looking Glass Bridge [version]\runtime` (headers)
     and `C:\Program Files\Looking Glass\Looking Glass Bridge [version]` (libraries)
   - **macOS**: `/Applications/Looking Glass Bridge [version].app/Contents/runtime` (headers)
     and `/Applications/Looking Glass Bridge [version].app/Contents/MacOS` (libraries)

#### Legacy HoloPlayCore SDK Support

For legacy displays (Looking Glass 8.9", 15.6", original 16" and 8K Gen1), you can still use
the older HoloPlayCore SDK. However, we recommend using Bridge SDK as it supports both legacy
and modern displays.

The legacy SDK is described [here](https://docs.lookingglassfactory.com/legacy/legacy-software/core-sdk).

### CMake Configuration of VTK

When configuring VTK using CMake, enable this remote module and its dependencies by setting:

1. `VTK_MODULE_ENABLE_VTK_RenderingLookingGlass` to `YES`
2. `VTK_USE_VIDEO_FOR_WINDOWS` to `ON` (Windows only)
3. `VTK_USE_MICROSOFT_MEDIA_FOUNDATION` to `ON` (Windows only)

The CMake configuration will automatically search for the Bridge SDK in the standard Looking Glass
Bridge installation directories. If the SDK is not found automatically, you can manually specify:

1. `BridgeSDK_INCLUDE_DIR` - Path to the `bridge.h` header (e.g., `C:/Program Files/Looking Glass/Looking Glass Bridge 2.6.0/runtime`)
2. `BridgeSDK_LIBRARY` - Path to the Bridge SDK library (e.g., `C:/Program Files/Looking Glass/Looking Glass Bridge 2.6.0/HoloPlayCore.lib`)

**Note:** For backward compatibility, the old `HoloPlayCore_INCLUDE_DIR` and `HoloPlayCore_LIBRARY`
variables are still supported and will be mapped to the Bridge SDK paths.

### Compilation

### Running VTK applications

The Bridge SDK uses shared libraries (DLLs on Windows, dylibs on macOS, SOs on Linux) that must be
accessible at runtime.

**Important:** You must have Looking Glass Bridge running for the application to connect to Looking
Glass displays.

#### Windows
Add the Bridge installation directory to your PATH:
```
set PATH=%PATH%;C:\Program Files\Looking Glass\Looking Glass Bridge 2.6.0
```

#### macOS
Add the Bridge application bundle to your library path:
```
export DYLD_LIBRARY_PATH=/Applications/Looking Glass Bridge 2.6.0.app/Contents/MacOS:$DYLD_LIBRARY_PATH
```

#### Linux
Add the Bridge library directory to your LD_LIBRARY_PATH (when Linux support is available).

System-level access to the shared libraries is required for both C++ applications and Python-wrapped
VTK when this module is enabled.nabled.

System-level access to the shared libs is also required when running the
Python wrapped VTK if this module was enabled when it was compiled.

### Rendering to a display and generating Quilts

The key functionality of this module is held in the `vtkLookingGlassInterface`
class.  It is used by the render window classes and by the render pass
implementations. This module is even capable of creating distributable quilt
images even if no Looking Glass hardware is present.

### Building and running the C++ tests

In order to build and run the C++ tests, this module must be built from
within VTK (see [the required CMake settings](#cmake-configuration-of-vtk))
with the additional CMake flag `-DVTK_BUILD_TESTING=ON`.

After building, within the build directory, the tests should be located
in `./bin/vtkLookingGlassCxxTests`, and the test data should be located in
`./ExternalData/Testing/`. The tests may be executed like the following:

```bash
./bin/vtkLookingGlassCxxTests TestDragon -D ./ExternalData/Testing/ -I
./bin/vtkLookingGlassCxxTests TestLookingGlassPass -D ./ExternalData/Testing/ -I
```

Where the `-D` flag provides the location of the test data directory,
and the `-I` indiciates that the test should run interactively (otherwise,
the application will render once and close immediately).

## Developement/Bug Reports

If you run into issues with this module please submit a bug report at
https://github.com/Kitware/LookingGlassVTKModule/issues

## License

See LICENSE file.
