#!/bin/sh
# 用法
# ./request.sh "https://m.baidu.com/suggest?empty_field=10000&ctl=his&action=list&cfrom=1099a&ds_lv=7&ds_stc=0.7740&from=1099a&matrixstyle=0&network=1_0&osbranch=i0&osname=baiduboxapp&puid=_u2Kt_OQv8SlmqqqB&service=bdbox&st=0&ua=828_1792_iphone_12.17.0.1_0&uid=45D34CA04432AE7FB8F806F7483DB2F06B58F8588FMMDBHJSRH&ut=iPhone11%2C8_12.1.2&zid=MowzQoEcY-nekbrCSe81hD2bEiGt5Q1itnKJo6S65D3FjREtnYW0pP9JS34FZAoGMXNM_cO7KynfHotkJEntNbw" response

curl -X POST "$1" -H @./header -d @./x-www-form-urlencoded -o "$2" -# -i -v
