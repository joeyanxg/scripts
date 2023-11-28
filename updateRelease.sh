#!/bin/bash
# locate some directories
cd "$(dirname $0)"
#cd ../..
TOP="${PWD}"
TARGET_BASE="remac_release1127"
PACK_NAME="CodeRelease1127"
MAKESOURCE="remac1011/mtk_git"
SOURCE="$TOP/$MAKESOURCE"
SOURCE_OUT="$SOURCE/out/target/product/aiot8365p2_64_bsp/"
TARGET="$TOP/$TARGET_BASE"
TARGET_OUT="$TARGET/out/target/product/aiot8365p2_64_bsp/"

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
function Copy_out(){
	mkdir $TARGET/out/host/linux-x86/bin -p
	cp $SOURCE/out/host/linux-x86/bin/avbtool $TARGET/out/host/linux-x86/bin/
	cp $SOURCE/out/host/linux-x86/bin/e2fsdroid $TARGET/out/host/linux-x86/bin/
	cp $SOURCE/out/host/linux-x86/bin/fec $TARGET/out/host/linux-x86/bin/
	cp $SOURCE/out/host/linux-x86/bin/mke2fs $TARGET/out/host/linux-x86/bin/
	cp $SOURCE/out/host/linux-x86/bin/mke2fs.conf $TARGET/out/host/linux-x86/bin/
	cp $SOURCE/out/host/linux-x86/bin/mkuserimg_mke2fs.sh $TARGET/out/host/linux-x86/bin/
	cp $SOURCE/out/host/linux-x86/bin/simg2img $TARGET/out/host/linux-x86/bin/
	mkdir $TARGET/out/host/linux-x86/framework -p
	cp $SOURCE/out/host/linux-x86/framework/signapk.jar $TARGET/out/host/linux-x86/framework/
	mkdir $TARGET/out/host/linux-x86/lib64 -p
	cp $SOURCE/out/host/linux-x86/lib64/libbase.so $TARGET/out/host/linux-x86/lib64/
	cp $SOURCE/out/host/linux-x86/lib64/libbrotli.so $TARGET/out/host/linux-x86/lib64/
	cp $SOURCE/out/host/linux-x86/lib64/libc++.so $TARGET/out/host/linux-x86/lib64/
	cp $SOURCE/out/host/linux-x86/lib64/libconscrypt_openjdk_jni.so $TARGET/out/host/linux-x86/lib64/
	cp $SOURCE/out/host/linux-x86/lib64/liblog.so $TARGET/out/host/linux-x86/lib64/
	mkdir $TARGET_OUT/obj/ETC -p
	cp $SOURCE_OUT/data $TARGET_OUT/ -rf
	cp $SOURCE_OUT/obj/ETC/file_contexts.bin_intermediates $TARGET_OUT/obj/ETC/ -rf
	cp $SOURCE_OUT/obj/PACKAGING/systemimage_intermediates $TARGET_OUT/obj/PACKAGING/ -rf
	cp $SOURCE_OUT/recovery $TARGET_OUT/ -rf
	cp $SOURCE_OUT/root $TARGET_OUT/ -rf
	cp $SOURCE_OUT/system $TARGET_OUT/ -rf
	cp $SOURCE/out/host/linux-x86/bin/brotli $TARGET/out/host/linux-x86/bin/
	cp $SOURCE/out/dist/full_aiot8365p2_64_bsp-target_files-eng.xiaoguang.zip $TARGET_OUT -rf
}

function Copy_full(){
	################copy build####################
	cp $SOURCE/build $TARGET -rf
	################copy device####################
	mkdir $TARGET/device/mediatek -p
	cp $SOURCE/device/mediatek/build $TARGET/device/mediatek/ -rf
	cp $SOURCE/device/mediatek/common $TARGET/device/mediatek/ -rf
	cp $SOURCE/device/mediatek/mt8168 $TARGET/device/mediatek/ -rf
	cp $SOURCE/device/mediateksample $TARGET/device/ -rf
	################copy out####################
	Copy_out
	################copy pkg####################
	mkdir $TARGET/pkg -p 
	cp $SOURCE_OUT*.bin $TARGET/pkg -rf
	cp $SOURCE_OUT*.img $TARGET/pkg -rf
	cp $SOURCE_OUT/GPT $TARGET/pkg -rf
	cp $SOURCE_OUT/MT8168* $TARGET/pkg -rf
	################copy prebuilts####################
	mkdir $TARGET/prebuilts/build-tools/linux-x86/bin -p
	cp $SOURCE/prebuilts/build-tools/linux-x86/bin/ckati $TARGET/prebuilts/build-tools/linux-x86/bin/
	cp $SOURCE/prebuilts/build-tools/linux-x86/bin/ninja $TARGET/prebuilts/build-tools/linux-x86/bin/
	mkdir $TARGET/prebuilts/build-tools/linux-x86/lib64 -p
	cp $SOURCE/prebuilts/build-tools/linux-x86/lib64/libc++.so $TARGET/prebuilts/build-tools/linux-x86/lib64/
	mkdir $TARGET/prebuilts/go/ -p
	cp $SOURCE/prebuilts/go/linux-x86 $TARGET/prebuilts/go/ -rf
	################copy system####################
	mkdir $TARGET/system/extras/ext4_utils -p
	cp $SOURCE/system/extras/ext4_utils/mke2fs.conf $TARGET/system/extras/ext4_utils/
	mkdir $TARGET/system/update_engine -p
	cp $SOURCE/system/update_engine/scripts $TARGET/system/update_engine/ -rf
}

function Update(){
	time_start=$(date "+%Y-%m-%d %H:%M:%S")
	cd $SOURCE
	source build/envsetup.sh
	lunch full_aiot8365p2_64_bsp-userdebug
	if [ $? == 0 ];then
		echo "lunch success!"
	else
		echo "lunch failed!"
		exit 1
	fi

	echo "Cleaning build, please wait..."
	make clean -j32 2>&1 | tee make-clean.log
	if [ $? == 0 ];then
		echo "make clean success!"
	else
		echo "make clean failed!"
		exit 1
	fi

	if [ ! -e $TARGET ];then
		mkdir $TARGET -p
	fi

	#Copy_full

	make dist -j64 2>&1 | tee makeDist-$date.log
	if [ $? == 0 ];then
		echo "make dist success!"
	else
		echo "make dist failed!"
		exit 1
	fi

	Copy_full

	cd $TARGET

	cp $TOP/build.sh $TARGET/

	bash build.sh

	if [ $? == 0 ];then
		echo "build.sh exec success!"
		rm $TARGET/out -rf
		Copy_out
	else
		echo "build.sh exec failed!"
		exit 1
	fi

	time_end=$(date "+%Y-%m-%d %H:%M:%S")
	time=$(($(date +%s -d "${time_end}")-$(date +%s -d "${time_start}")));
	result=$(calculate $time)
	echo "updateRelease success!##### $result #####"
	
	echo "Start package releasecode"
	time_start1=$(date "+%Y-%m-%d %H:%M:%S")
	cd ~
	tar -zcvf $PACK_NAME.tar.gz $TARGET_BASE
	time_end1=$(date "+%Y-%m-%d %H:%M:%S")
	time1=$(($(date +%s -d "${time_end1}")-$(date +%s -d "${time_start1}")));
	result1=$(calculate $time1)
	echo "package success!##### $result1 #####"
}

while true;do
	stty -icanon
	echo -n "Please check device.mk already modify(yes or no)?"
	read var
	case $var in
		Y|y|YES|yes)
		  Update
		  break;;
		N|n|NO|no)
		  echo -n "Please mark copy bonlaway.tar.gz and datalib.tar.gz in $MAKESOURCE/device/mediatek/common/device.mk "
		  break;;
	esac
done