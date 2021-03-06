#!/bin/sh
function help() {
	echo "*****************************"
	echo "使用帮助:"
	echo "-s 项目scheme的名称，必填"
	echo "-w 项目workspace的名称，可选, 默认使用scheme的名称"
	echo "-d 是否在Debug环境下打包, 0: 在Release环境下 1： 在Debug环境下，默认0"
	echo "-o 打包完成后是否自动打开文件夹，1：打开 0：不打开。默认为1，打开"  
	echo "使用范例: makeFramework -s MyProject -d 1"
	echo "*****************************"
}

#scheme名称
scheme_name=''
workspace_name=''
framework_name=''
configuration='Release'
open_when_done=true

while getopts "s:w:f:do:" opt; do
	case $opt in 
		s )
scheme_name=$OPTARG
			;;
		w )
workspace_name=$OPTARG
            ;;
	    d )
configuration='Debug'
			;;
		o )
if [ $OPTARG == 0 ]; then
	open_when_done=false
else 
	open_when_done=true
fi
			;;
	esac
done

if [[ $scheme_name == "" ]]; then
	echo "scheme_name不能为空, 请查看帮助如下:"
	help
	exit 1
fi

if [[ $workspace_name == "" ]]; then
	workspace_name=$scheme_name
fi

if [[ $framework_name == "" ]]; then
	framework_name=$scheme_name
fi

showConfigurations(){
	echo "**********项目当前配置信息**********"
	echo "scheme_name: $scheme_name"
	echo "workspace_name: $workspace_name"
	echo "framework_name: $framework_name"
	echo "configuration: $configuration"
	echo "完成后是否自动打开文件夹: $open_when_done"

}

showConfigurations

checkWorkspace(){
	echo "***********************"
	workspace_exist=`ls | grep "^${workspace_name}.xcworkspace$" | wc -l`
	if [ ${workspace_exist} == 1 ]; then
		echo "检测到workspace文件：${workspace_name}.xcworkspace"
	else
		echo "当前路径下没有检测到对应的workspace文件，请检查项目是否包含, 再重新尝试"
		exit 1
	fi
}

checkWorkspace

CURRENT_PATH=`pwd`
FRAMEWORK_DIR=${CURRENT_PATH}/${workspace_name}Framework
BUILD_DIR_TMP="${CURRENT_PATH}/${workspace_name}Build"
BUILD_SETTINGS="ONLY_ACTIVE_ARCH=NO enableCodeCoverage=NO MACH_O_TYPE=staticlib SYMROOT=${BUILD_DIR_TMP}"
IPHONE_SIMULATOR="iphonesimulator"
IPHONE_OS="iphoneos"
IPHONE_SIMULATOR_FRAMEWORK=${BUILD_DIR_TMP}/${configuration}-${IPHONE_SIMULATOR}/${framework_name}.framework
IPHONE_OS_FRAMEWORK=${BUILD_DIR_TMP}/${configuration}-${IPHONE_OS}/${framework_name}.framework

clean(){ 
if [[ -d $FRAMEWORK_DIR ]]; then
		rm -rf $FRAMEWORK_DIR
	fi	
if [[ -d $BUILD_DIR_TMP ]]; then
	rm -rf $BUILD_DIR_TMP
fi
}

xcodeBuild(){
	clean
	mkdir -p ${BUILD_DIR_TMP}
	xcodebuild clean -workspace ${workspace_name}.xcworkspace -scheme ${scheme_name}
	xcodebuild build -workspace ${workspace_name}.xcworkspace -scheme ${scheme_name} -configuration $configuration -sdk $IPHONE_SIMULATOR ${BUILD_SETTINGS}
	xcodebuild build -workspace ${workspace_name}.xcworkspace -scheme ${scheme_name} -configuration $configuration -sdk $IPHONE_OS ${BUILD_SETTINGS}
}

xcodeBuild

mergeFramework(){
	architecturesInfo=(echo `lipo -info ${IPHONE_SIMULATOR_FRAMEWORK}/${framework_name} | grep arm64`)
	if [[ $architecturesInfo != "" ]]; then
	 		lipo ${IPHONE_SIMULATOR_FRAMEWORK}/${framework_name} -remove arm64 -output ${IPHONE_SIMULATOR_FRAMEWORK}/${framework_name}
	 fi 
	lipo -create ${IPHONE_SIMULATOR_FRAMEWORK}/${framework_name} ${IPHONE_OS_FRAMEWORK}/${framework_name} -output ${IPHONE_SIMULATOR_FRAMEWORK}/${framework_name}

	mkdir -p ${FRAMEWORK_DIR}
	cp -R $IPHONE_SIMULATOR_FRAMEWORK $FRAMEWORK_DIR 
	find ${FRAMEWORK_DIR}/${framework_name}.framework -maxdepth 1 -name "*.bundle" -not -name "${workspace_name}.bundle" | xargs rm -rf
	rm -rf BUILD_DIR_TMP

	if [[ $open_when_done == true ]]; then
		echo "自动打开文件夹"
		open $FRAMEWORK_DIR
	fi
}

mergeFramework


