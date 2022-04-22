#!/opt/homebrew/bin/python3

import lief


xcode_fat = lief.MachO.parse("/Applications/Xcode.app/Contents/MacOS/Xcode")
xcode = xcode_fat.take(lief.MachO.CPU_TYPES.ARM64) # or `x86_64` for Intel-based Mac

patch_lib = lief.MachO.DylibCommand.weak_lib('/usr/local/lib/libXcodePatch.dylib')

xcode.add(patch_lib)

xcode.write("/Applications/Xcode.app/Contents/MacOS/Xcode")