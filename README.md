
### 背景
> [Xcode 是我使用过最糟糕的开发工具][1]。Xcode 13.3 introduced a very annoying bug. When you type anything with Chinese IME in the LLDB console, the whole app freezes! I did some investigation and fixed this issue before Apple publishes the next release.

&emsp; &emsp; 最近我更新了最新的`Xcode(13.3.1)`，每次`Debug`都得心惊胆战的看看电脑右上角输入法，才能安心调试，每次调试都感觉到心累与烦恼，一不小心只能`Force Quit`重来。


### 解决方案
- 解决当前版本的中文输入问题
- 回退旧版本(`Xcode 13.3`以前的版本)

---

&emsp; &emsp; 于是我选择了第一种解决方案，经过一番探索与实践，在`Github`上找到了一个补丁 [XcodePatch][XcodePatch] (当然我还没有写补丁的能力，源于对`Xcode`还不够了解)，成功解决了`Debug`中文输入问题。</br>
&emsp; &emsp; 为了方便大家使用，我给大家编译好了 [libXcodePatch.dylib][initXcodePatch] 动态库，并且写了一个脚本 [initXcodePatch][initXcodePatch] 方便大家使用。我也总结了我再此过程中遇到的问题，方便大家参考。</br>

在执行脚本前，请确定你`本地环境`已经安装对应的程序,并已经`备份Xcode`

```bash
hanson at Hanson-C in ~/Desktop/Xcodeinjection
$ which python3
/opt/homebrew/bin/python3
# 检查 Python3 安装路劲是否正确，不正确需要修改.py文件
# Xcode 路劲为 /Applications/Xcode.app

hanson at Hanson-C in ~/Desktop/Xcodeinjection
$ cmake --version
cmake version 3.23.1
```


`执行以下脚本，补丁就能成功安装了`下载地址 [initXcodePatch][initXcodePatch]

```bash
hanson at Hanson-C in ~/Desktop/Xcodeinjection
$ ./initXcodePatch.sh
1. M1 芯片电脑
2. Intel 芯片电脑
请选择你电脑类型：
1
你选的是 M1 芯片电脑! 执行代码需要超级管理员权限，请输入您电脑密码.
Password:
```


### 遇到问题
- 安装`lief`报错
- 补丁修复后，`Xcode` 编译`iOS`项目不成功

> 第一个问题：通过日志看出，`CMake` 有问题，检查一下是`CMake`未安装
```bash
hanson at Hanson-C in ~
$ pip3 install lief
DEPRECATION: Configuring installation scheme with distutils config files is deprecated and will no longer work in the near future. If you are using a Homebrew or Linuxbrew Python, please see discussion at https://github.com/Homebrew/homebrew-core/issues/76621
Collecting lief
  Using cached lief-0.12.1.zip (15.0 MB)
  Preparing metadata (setup.py) ... done
Building wheels for collected packages: lief
  Building wheel for lief (setup.py) ... error
  error: subprocess-exited-with-error

  × python setup.py bdist_wheel did not run successfully.
  │ exit code: 1
  ╰─> [51 lines of output]
      /private/var/folders/jp/bjy7xth91k35wdx9v2221t6h0000gn/T/pip-install-hpb266lc/lief_80c30ac3e65b4114a60a863ff4463c8b/setup.py:19: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
        assert (LooseVersion(setuptools.__version__) >= LooseVersion(MIN_SETUPTOOLS_VERSION)), "LIEF requires a setuptools version '{}' or higher (pip install setuptools --upgrade)".format(MIN_SETUPTOOLS_VERSION)
      0.12.1
      running bdist_wheel
      running build
      running build_ext
      Traceback (most recent call last):
        File "/private/var/folders/jp/bjy7xth91k35wdx9v2221t6h0000gn/T/pip-install-hpb266lc/lief_80c30ac3e65b4114a60a863ff4463c8b/setup.py", line 91, in run
          subprocess.check_output(['cmake', '--version'])
          ....
        File "/private/var/folders/jp/bjy7xth91k35wdx9v2221t6h0000gn/T/pip-install-hpb266lc/lief_80c30ac3e65b4114a60a863ff4463c8b/setup.py", line 93, in run
          raise RuntimeError("CMake must be installed to build the following extensions: " +
      RuntimeError: CMake must be installed to build the following extensions: lief
      [end of output]

  note: This error originates from a subprocess, and is likely not a problem with pip.
error: legacy-install-failure

× Encountered error while trying to install package.
╰─> lief

note: This is an issue with the package mentioned above, not pip.
hint: See above for output from the failure.
```
> `解决方案`
```bash
hanson at Hanson-C in ~ 
$ brew install cmake

hanson at Hanson-C in ~ 
$ cmake --version
# cmake version 3.23.1
```

---

> 第二个问题：怀疑动态库修改后加载有问题，查看补丁源码，源码编译过程</br>
> 电脑为 M1 芯片，编译时候选着不同
 ```bash
error: failed to read asset tags: The command `(cd /Users/hanson/Desktop/TestXcodePath && /Applications/Xcode.app/Contents/Developer/usr/bin/actool --print-asset-tag-combinations --output-format xml1 /Users/hanson/Desktop/TestXcodePath/TestXcodePath/Assets.xcassets)` terminated with uncaught signal 6. The command's standard error was:

\


dyld[4432]: Library not loaded: @rpath/AssetCatalogFoundation.framework/Versions/A/AssetCatalogFoundation

  Referenced from: /Applications/Xcode.app/Contents/Developer/usr/bin/ibtoold

  Reason: tried: '/Applications/Xcode.app/Contents/Developer/usr/bin/AssetCatalogFoundation.framework/Versions/A/AssetCatalogFoundation' (no such file), '/Applications/Xcode.app/Contents/Developer/usr/bin/../../../Frameworks/AssetCatalogFoundation.framework/Versions/A/AssetCatalogFoundation' (code signature in <4E25B0D6-C059-3B91-8642-F965732139D4> '/Applications/Xcode.app/Contents/Frameworks/AssetCatalogFoundation.framework/Versions/A/AssetCatalogFoundation' not valid for use in process: mapped file has no Team ID and is not a platform binary (signed with custom identity or adhoc?)), '/Applications/Xcode.app/Contents/Developer/usr/bin/../../../SharedFrameworks/AssetCatalogFoundation.framework/Versions/A/AssetCatalogFoundation' (no such file), '/Applications/Xcode.app/Contents/Developer/usr/bin/../../../PlugIns/AssetCatalogFoundation.framework/Versions/A/AssetCatalogFoundation' (no such file), '/Applications/Xcode.app/Contents/Developer/usr/bin/AssetCatalogFoundation.framework/Versions/A/AssetCatalogFoundation' (no such file), '/Applications/Xcode.app/Contents/Developer/usr/bin/../../../Frameworks/AssetCatalogFoundation.framework/Versions/A/AssetCatalogFoundation' (code signature in <4E25B0D6-C059-3B91-8642-F965732139D4> '/Applications/Xcode.app/Contents/Frameworks/AssetCatalogFoundation.framework/Versions/A/AssetCatalogFoundation' not valid for use in process: mapped file has no Team ID and is not a platform binary (signed with custom identity or adhoc?)), '/Applications/Xcode.app/Contents/Developer/usr/bin/../../../SharedFrameworks/AssetCatalogFoundation.framework/Versions/A/AssetCatalogFoundation' (no such file), '/Applications/Xcode.app/Contents/Developer/usr/bin/../../../PlugIns/AssetCatalogFoundation.framework/Versions/A/AssetCatalogFoundation' (no such file), '/Library/Frameworks/AssetCatalogFoundation.framework/Versions/A/AssetCatalogFoundation' (no such file), '/System/Library/Frameworks/AssetCatalogFoundation.framework/Versions/A/AssetCatalogFoundation' (no such file)

 (in target 'TestXcodePath' from project 'TestXcodePath')
```

> `解决方案`</br>
> 重新编译`M1`版本的动态库，重新替换一遍，可以解决了以上这个问题，还存在一个问题是`模拟器无法使用`


[1]:https://www.reddit.com/r/iOSProgramming/comments/fmys59/xcode_is_worst_ide_i_have_ever_used/
[XcodePatch]:https://github.com/unixzii/XcodePatch
[initXcodePatch]:https://github.com/Hansoncoder/InjectionXcodePatch