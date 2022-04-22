#!/bin/bash

demoFun(){
    if [ $1 -eq 1 ]; then
        echo "你选的是 M1 芯片电脑! 执行代码需要超级管理员权限，请输入您电脑密码."
        sudo cp "./M1/libXcodePatch.dylib"  /usr/local/lib/
    else
        echo "你选的是 Intel 电脑! 执行代码需要超级管理员权限，请输入您电脑密码."
        sudo cp "./Intel/libXcodePatch.dylib"  /usr/local/lib/
    fi
}

echo "1. M1 芯片电脑"
echo "2. Intel 芯片电脑"
echo "请选择你电脑类型："
read cpu
demoFun $cpu
echo "动态库准备完毕，开始注入二进制文件"
python3 injectPatch.py
echo "动态库注入成功，开始重签名Xcode"
python3 ResignXcode.py
