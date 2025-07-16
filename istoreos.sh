#!/bin/bash
mkdir -p openwrt

# 判断本脚本中的环境变量是否有效，如果无效则传入另外一个环境变量。
if [ -z "$VLATEST_TAG" ]; then
    LATEST_TAG=$LATEST22_TAG
else
    LATEST_TAG=$LATEST_TAG
fi

if [ -z "$VLATEST_TIME" ]; then
    LATEST_TIME=$LATEST22_TIME
else
    LATEST_TIME=$LATEST_TIME
fi


# REPO="wukongdaily/img-installer"
# TAG="2025-07-15"
FILE_NAME="istoreos-$LATEST_TAG-$LATEST_TIME-x86-64-squashfs-combined-efi.img.gz"
OUTPUT_PATH="openwrt/istoreos.img.gz"
# DOWNLOAD_URL=$(curl -s https://api.github.com/repos/$REPO/releases/tags/$TAG | jq -r '.assets[] | select(.name == "'"$FILE_NAME"'") | .browser_download_url')
DOWNLOAD_URL="https://dl.istoreos.com/iStoreOS/x86_64_efi/$FILE_NAME"

echo "LATEST_TIME: $LATEST_TIME"
echo "LATEST_TAG: $LATEST_TAG"
echo "FILE_NAME: $FILE_NAME" 

if [[ -z "$DOWNLOAD_URL" ]]; then
  echo "错误：未找到文件 $FILE_NAME"
  exit 1
fi

echo "下载地址: $DOWNLOAD_URL"
echo "下载文件: $FILE_NAME -> $OUTPUT_PATH"
curl -L -o "$OUTPUT_PATH" "$DOWNLOAD_URL"

if [[ $? -eq 0 ]]; then
  echo "下载istoreos成功!"
  echo "正在解压为:istoreos.img"
  gzip -d openwrt/istoreos.img.gz
  ls -lh openwrt/
  echo "准备合成 istoreos 安装器"
else
  echo "下载失败！"
  exit 1
fi

mkdir -p output
docker run --privileged --rm \
        -v $(pwd)/output:/output \
        -v $(pwd)/supportFiles:/supportFiles:ro \
        -v $(pwd)/openwrt/istoreos.img:/mnt/istoreos.img \
        debian:buster \
        /supportFiles/istoreos/build.sh $LATEST_TAG $LATEST_TIME
