function imgClick(src, index, width, height, top) {
    // 完整
    //window.location.href = "sx:src="+src+"&index="+index+"&width="+width+"&height="+height+"&top="+top;
    
    // 精简
    window.location.href = "sx:"+src+"&"+index+"&"+width+"&"+height+"&"+top;
    
    // 弹框
    //alert("sx:"+src+"&"+index+"&"+width+"&"+height+"&"+top);
    
    // 测试使用
    //window.location.href = "sx://www.baidu.com";
    //window.location.href = "www.baidu.com";
    
    // 测试使用
    //window.location.href = "sx"+src;
}

function digestClick(digest) {
    alert(digest);
}
