/*=========================================================================

  Copyright (c) 2020 Kitware, Inc.
  All rights reserved.
  See Copyright.txt or http://www.kitware.com/Copyright.htm for details.

     This software is distributed WITHOUT ANY WARRANTY; without even
     the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
     PURPOSE.  See the above copyright notice for more information.

=========================================================================*/
#include "vtkCocoaLookingGlassRenderWindow.h"

#define className vtkCocoaLookingGlassRenderWindow
#include "vtkLookingGlassRenderWindowImpl.h"

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>
#import <IOKit/graphics/IOGraphicsLib.h>
#include "bridge.h"

//------------------------------------------------------------------------------
void vtkCocoaLookingGlassRenderWindow::Initialize()
{
  // Get device index
  int deviceIndex = this->Interface->GetDeviceIndex();

  // Get display indices
  int num_displays = 0;
  get_displays(&num_displays, nullptr);
  if (num_displays == 0)
  {
    this->Superclass::Initialize();
    return;
  }

  std::vector<unsigned long> display_indices(num_displays);
  get_displays(&num_displays, display_indices.data());

  if (deviceIndex >= num_displays)
  {
    deviceIndex = 0;
  }

  unsigned long display_index = display_indices[deviceIndex];

  // Get device name
  int name_count = 0;
  get_device_name_for_display(display_index, &name_count, nullptr);
  std::vector<wchar_t> device_name_wchar(name_count);
  get_device_name_for_display(display_index, &name_count, device_name_wchar.data());
  std::wstring name_wstr(device_name_wchar.begin(), device_name_wchar.end());
  std::string deviceName(name_wstr.begin(), name_wstr.end());

  // Default to display 1, assuming the LG display is the only auxilliary display
  int displayId = 1;

  // Explicitly look for the LG display
  int screenIndex = 0;
  NSArray *screens = [NSScreen screens];
  for (NSScreen *screen in screens)
  {
    int currentDisplayID = [[[screen deviceDescription] valueForKey:@"NSScreenNumber"] intValue];
    NSDictionary *deviceInfo =
      (NSDictionary *)CFBridgingRelease(IODisplayCreateInfoDictionary(CGDisplayIOServicePort(currentDisplayID),
                                                                      kIODisplayOnlyPreferredName));
    NSDictionary *localizedNames = [deviceInfo objectForKey:[NSString stringWithUTF8String:kDisplayProductName]];

    NSString *screenName = nil;
    if ([localizedNames count] > 0) {
      screenName = [localizedNames objectForKey:[[localizedNames allKeys] objectAtIndex:0]];
      std::string screenNameString = std::string([screenName UTF8String]);
      if (screenNameString == deviceName)
      {
        displayId = screenIndex;
        break;
      }
    }
    ++screenIndex;
  }
  this->SetDisplayId(&displayId);

  this->Superclass::Initialize();
}
