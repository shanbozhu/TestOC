#!/bin/sh
# 用法
# ./request.sh "https://mbd.baidu.com/icomment/v1/comment/list?appname=baiduboxlite&cfrom=1005640h&from=1005640h&fv=12.1.0.0&matrixstyle=0&network=1_0&sid=6566_12070-6565_12068-5748_8984-5583_8566-5682_8784-5534_8296-7254_14771-6973_13646-5957_9811-5601_8529-5987_9960-6197_10730-6170_10622-5463_8044-3000127_1-159_4-5558_8367-5644_8666-6110_10431-5483_8131-6358_11300-6375_11363&st=0&ua=828_1792_iphone_5.1.1.10_0&uid=45D34CA04432AE7FB8F806F7483DB2F06B58F8588FMMDBHJSRH&ut=iPhone11%2C8_12.1.2&zid=Nz1vfc_o7oN3ci-TIwM1lwW9-GqQg2jHJyLNp9nVbRIHhgbIVW4OVnCeiRhpIqEjYXcbGrU5UQymp2JPdo_EmqA&sdkversion=1.1.2" response

curl -X POST "$1" -H @./header -d @./json -o "$2" -# -i -v
