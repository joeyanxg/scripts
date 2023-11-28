#!/bin/bash

cd "$(dirname $0)"
TOP="${PWD}"
OUT_DIR="$TOP/out/target/product/aiot8365p2_64_bsp"
PKG="$TOP/pkg"
function ceil(){
floor=`echo "scale=0;$1/1"|bc -l ` # 向下取整
add=`awk -v num1=$floor -v num2=$1 'BEGIN{print(num1<num2)?"1":"0"}'`
echo `expr $floor + $add`
}

function calculate(){
	hour=`ceil $(($1/3600))`

	if [ $hour -gt 0 ];then
		temp_time=`expr $1 % 3600`
	else
		temp_time=$1
	fi
	min=`ceil $(($temp_time/60))`

	sec=`expr $temp_time % 60`
	if [ $hour -lt 10 ];then
		if [ $min -lt 10 ];then
			if [ $sec -lt 10 ];then
				echo "0$hour:0$min:0$sec"
			else
				echo "0$hour:0$min:$sec"
			fi
		else
			if [ $sec -lt 10 ];then
				echo "0$hour:$min:0$sec"
			else
				echo "0$hour:$min:$sec"
			fi
		fi
	else
		if [ $min -lt 10 ];then
			if [ $sec -lt 10 ];then
				echo "$hour:0$min:0$sec"
			else
				echo "$hour:0$min:$sec"
			fi
		else
			if [ $sec -lt 10 ];then
				echo "$hour:$min:0$sec"
			else
				echo "$hour:$min:$sec"
			fi
		fi
	fi
}
time_start=$(date "+%Y-%m-%d %H:%M:%S")
cd $TOP
source build/envsetup.sh
lunch full_aiot8365p2_64_bsp-userdebug
if [ $? == 0 ];then
	echo "lunch success!"
else
	echo "lunch failed!"
	exit 1
fi
if [ ! -e $PKG ];then
	mkdir $PKG -p
else
	#rm $PKG/* -rf
	echo "pkg already exist!"
fi

echo "package system start!!!"
cp $TOP/device/mediatek/mt8168/mpadlib/bonlaway.tar.gz $TOP/out/target/product/aiot8365p2_64_bsp/system/etc/oem/ -rf
cp $TOP/device/mediatek/mt8168/mpadlib/appstart.sh $TOP/out/target/product/aiot8365p2_64_bsp/system/etc/oem/ -rf
cp $TOP/device/mediatek/mt8168/mpadlib/datalib.tar.gz $TOP/out/target/product/aiot8365p2_64_bsp/system/etc/oem/ -rf
for file in $TOP/out/target/product/aiot8365p2_64_bsp/root/*
do
    if [ -e $file/.gitkeep ]; then
		rm $file/.gitkeep
	fi
done

for file in $TOP/out/target/product/aiot8365p2_64_bsp/recovery/root/*
do
    if [ -e $file/.gitkeep ]; then
		rm $file/.gitkeep
	fi
done
$TOP/build/tools/releasetools/build_image.py $OUT_DIR/system $OUT_DIR/obj/PACKAGING/system_image_info.txt $PKG/system.img $PKG
if [ $? == 0 ];then
	echo "package system success!"
else
	echo "package system failed!"
	exit 1
fi

echo "package otapkg start!!!"
mkdir -p $TOP/ota 
cp $OUT_DIR/full_aiot8365p2_64_bsp-target_files-eng.xiaoguang.zip $TOP/ota/target-eng.zip
if [ $? == 0 ];then
	mkdir -p $TOP/ota/IMAGES/
	cp $PKG/system.img $TOP/ota/IMAGES/ -rf
	#zip -qrym $TOP/ota/target-eng.zip $TOP/ota/
	cd $TOP/ota/
	zip -u target-eng.zip IMAGES/system.img
	rm $TOP/ota/IMAGES/ -rf
	$TOP/build/tools/releasetools/ota_from_target_files --block -p $TOP/out/host/linux-x86/ -k $TOP/build/target/product/security/testkey -v $TOP/ota/target-eng.zip  $TOP/ota/ota_update.zip
	if [ $? == 0 ];then
		echo "package otapkg success"
	else
		echo "package otapkg failed!"
		exit 1
	fi
	rm $TOP/ota/target-eng.zip -rf
	echo "package complete!!!"
else
	echo "target package file not exist! stop otapkg package"
	exit 1
fi

time_end=$(date "+%Y-%m-%d %H:%M:%S")
time=$(($(date +%s -d "${time_end}")-$(date +%s -d "${time_start}")));
result=$(calculate $time)
echo "##### $result #####"
