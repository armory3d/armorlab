![](https://armorlab.org/img/git.jpg)

armorlab (wip - issue reporting opening soon)
==============

[ArmorLab](https://armorlab.org) is a software for AI-powered texture authoring - check out the [manual](https://armorlab.org/manual).

*Note 1: This repository is aimed at developers and may not be stable. Distributed binaries are [paid](https://armorlab.org/download) to help with the project funding. All of the development is happening here in order to make it accessible to everyone. Thank you for support!*

*Note 2: If you are compiling git version of ArmorLab, then you need to have a compiler ([Visual Studio](https://visualstudio.microsoft.com/downloads/) - Windows, [clang](https://clang.llvm.org/get_started.html) + [deps](https://github.com/armory3d/armorpaint/wiki/Linux-Dependencies) - Linux, [Xcode](https://developer.apple.com/xcode/resources/) - macOS / iOS, [Android Studio](https://developer.android.com/studio) - Android), [nodejs](https://nodejs.org/en/download/) and [git](https://git-scm.com/downloads) installed.*

```bash
git clone --recursive https://github.com/armory3d/armorlab
cd armorlab
# Unpack `models.zip` from https://github.com/armory3d/armorlab_models/releases into `Assets/models` using 7-Zip - Extract Here
```

**Windows**
```bash
node armorcore/make -g direct3d11
cd armorcore
# Unpack `v8\libraries\win32\release\v8_monolith.7z` using 7-Zip - Extract Here (exceeds 100MB)
git apply patch/window_handling.diff --directory=Kinc
Kinc/make -g direct3d11
# Open generated Visual Studio project at `build\ArmorLab.sln`
# Build and run for x64 & release
```

**Linux**
```bash
node armorcore/make -g opengl
cd armorcore
Kinc/make -g opengl --compiler clang --compile
cd Deployment
strip ArmorLab
./ArmorLab ../../build/krom
```

**macOS**
```bash
node armorcore/make -g metal
cp -a build/krom/ armorcore/Deployment
cd armorcore
git apply patch/metal_depth.diff --directory=Kinc
Kinc/make -g metal
# Open generated Xcode project at `build/ArmorLab.xcodeproj`
# Build and run
```

**Android** *wip*
```bash
```

**iOS** *wip*
```bash
```

**Windows DXR** *wip*
```bash
node armorcore/make -g direct3d12
cd armorcore
# Unpack `v8\libraries\win32\release\v8_monolith.7z` using 7-Zip - Extract Here (exceeds 100MB)
git apply patch/window_handling.diff --directory=Kinc
git apply patch/d3d12_raytrace.diff --directory=Kinc
git apply patch/d3d12_wrap_sampler.diff --directory=Kinc
Kinc/make -g direct3d12
# Open generated Visual Studio project at `build\ArmorLab.sln`
# Build and run for x64 & release
```

**Linux VKRT** *wip*
```bash
node armorcore/make -g vulkan
cd armorcore
git apply patch/vulkan_raytrace.diff --directory=Kinc
git clone --recursive https://github.com/armory3d/glsl_to_spirv Libraries/glsl_to_spirv
Kinc/make -g vulkan --compiler clang --compile
cd Deployment
strip ArmorLab
./ArmorLab ../../build/krom
```

**Updating cloned repository**
```bash
git pull origin master
git submodule update --init --recursive
# Delete `armorlab/build` directory if present
```

**Generating a locale file**
```bash
pip install typing_extensions -t Assets/locale/tools
python ./Assets/locale/tools/extract_locales.py <locale code>
# Generates an `Assets/locale/<locale code>.json` file
```

**Release builds** *Optional, used for best performance*
```bash
# Compile krom.js using the closure compiler
https://developers.google.com/closure/compiler
# Generate a v8 snapshot file
node armorcore/make -g api --snapshot
./ArmorLab . --snapshot
# Generates a `krom.bin` file from `krom.js` file
```
