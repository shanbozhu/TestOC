#!/bin/sh
# 用法
# ./request.sh "https://mbd.baidu.com/icomment/v1/comment/rlist?appname=baiduboxlite&cfrom=1005640h&ds_lv=4&ds_stc=0.7740&from=1005640h&fv=13.30.0.10&matrixstyle=0&mps=154326807&mpv=1&network=1_0&sid=34836_3-8319_19556-56196_2-8313_19529-56785_2-56115_2-34064_2-35158_1-5760_9013-34999_8-35148_1-35262_2-107862_3-32205_2-56359_4-55371_1-35215_2-5280_7494-56512_4-9619_2-8321_19560-33923_6-9451_2-9618_2-8083_18570-5644_8666-56430_2-35223_1-5153_7043-34731_2-35072_2-56076_3&st=0&ua=828_1792_iphone_6.1.0.3_0&uid=45D34CA04432AE7FB8F806F7483DB2F06B58F8588FMMDBHJSRH&zid=Nz1vfc_o7oN3ci-TIwM1lwW9-GqQg2jHJyLNp9nVbRIFAsQJxD06HMqQTcbu6Y9x0StTFnWsNpHkiJhkxPtHb6Q&sdkversion=1.1.2" response

curl -X POST '$1' -H @./header -d @./json -o '$2' -# -i -v
