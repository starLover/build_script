# iOS打包脚本
## 打包前准备:
- 右键点击访达，选择前往文件夹，输入路径**usr/local/bin**, 前往该文件夹，将所需要的脚本文件拖拽进此文件夹即可，这样做的原因是为了是脚本可以在终端全局执行
### 1. Framework打包使用说明
- 进入项目的 **.xcworkspace** 所在的目录，执行下面的脚本
``` .bash
framework_build -s MyProject -d 0
#将MyPoject替换为自己项目的名字即可

********附加参数********
-s 项目scheme的名称，必填
-w 项目workspace的名称，可选, 默认使用scheme的名称
-d 是否在Debug环境下打包, 0: 在Release环境下 1： 在Debug环境下，默认0
-o 打包完成后是否自动打开文件夹，1：打开 0：不打开。默认为1，打开
如: framework_build -s MyProject -d 1 -o 0
***********************
```

