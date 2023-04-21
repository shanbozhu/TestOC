//
//  PBSwiftController.swift
//  TestOC
//
//  Created by Zhu,Shanbo on 2021/6/11.
//  Copyright © 2021 DaMaiIOS. All rights reserved.
//

/**
 // c、oc、swift各语言对比
 
 // c
 int sum(int a, int b) {}
 sum(3, 4);
 
 // oc
 - (int)sumWitha:(int)a b:(int)b {}
 [o sumWitha:3 b:4];
 
 // swift
 // "a a: int"第一个a是子标题,第二个a是变量
 func sum(a a: int, b b: int) -> int {}
 o.sum(a: 3, b: 4)
 // 不写子标题,子标题默认与变量同名
 fun sum(a: int, b: int) -> int {}
 o.sum(a: 3, b: 4)
 // "_"取消子标题
 func sum(_ a: int, b b: int) -> int {}
 o.sum(3, b: 4)
 */

import UIKit

class PBSwiftController: PBBaseController {
    func requestData(_ sinceId: Int, status: Int) {
        let requestUrl = "https://mbd.baidu.com/icomment/v1/comment/rlist?appname=baiduboxlite&cfrom=1005640h&ds_lv=4&ds_stc=0.7740&from=1005640h&fv=13.30.0.10&matrixstyle=0&mps=154326807&mpv=1&network=1_0&sid=34836_3-8319_19556-56196_2-8313_19529-56785_2-56115_2-34064_2-35158_1-5760_9013-34999_8-35148_1-35262_2-107862_3-32205_2-56359_4-55371_1-35215_2-5280_7494-56512_4-9619_2-8321_19560-33923_6-9451_2-9618_2-8083_18570-5644_8666-56430_2-35223_1-5153_7043-34731_2-35072_2-56076_3&st=0&ua=828_1792_iphone_6.1.0.3_0&uid=45D34CA04432AE7FB8F806F7483DB2F06B58F8588FMMDBHJSRH&zid=Nz1vfc_o7oN3ci-TIwM1lwW9-GqQg2jHJyLNp9nVbRIFAsQJxD06HMqQTcbu6Y9x0StTFnWsNpHkiJhkxPtHb6Q&sdkversion=1.1.2"
        
        let manager: AFHTTPRequestOperationManager = AFHTTPRequestOperationManager()
        manager.requestSerializer = AFHTTPRequestSerializer()
        manager.responseSerializer = AFHTTPResponseSerializer()
        
        var paras = self.requestHeaderAndBody(manager: manager)
        paras["sortTime"] = String(sinceId)
        
        weak var weakSelf = self
        manager.post(requestUrl, parameters: paras, success: { (operation: AFHTTPRequestOperation?, responseObject: Any?) in
            let jsonDict: [String : AnyObject] = try! JSONSerialization.jsonObject(with: responseObject as! Data, options: JSONSerialization.ReadingOptions.mutableContainers) as! [String : AnyObject]
            
            //weakSelf!.stringWithDictionary(jsonDict) // 页面被释放了,网络请求才回来,会崩溃
            weakSelf?.stringWithDictionary(jsonDict)
            
        }) { (operation: AFHTTPRequestOperation?, error :Error?) in
            print(error!)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = false // 取消自动调节ScrollView内边距
        
        // lab
        let lab: PBSwiftLabel = PBSwiftLabel()
        self.view.addSubview(lab)
        lab.frame = CGRect(x: 80, y: 150, width: 200, height: 0)
        lab.numberOfLines = 0
        lab.text = "这是用swift写的页面,发送了一个网络请求"
        lab.sizeToFit()
        
        self.requestData(0, status: 0)
    }
    
    deinit {
        print("PBSwiftController对象被释放了")
    }
    
    func requestHeaderAndBody(manager: AFHTTPRequestOperationManager) -> [String : String] {
        manager.requestSerializer.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 12_1_2 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/16C104 SP-engine/2.24.0 matrixstyle/0 info baiduboxapp/5.1.1.10 (Baidu; P2 12.1.2)", forHTTPHeaderField: "User-Agent")
        manager.requestSerializer.setValue("BAIDUCUID=gaS98giPH8_fu28xli2yu0PjHt_RaS8V_O2Ca0aMH8_ui2tY0O2NtYi2QP0z8WPCbWHmA; MBD_AT=1611037261; __yjs_duid=1_16ef112911fea7f8f85861dd4cd865d61611037267886; BDUSS=o4dG9PbFUyaHJ6YmlJUXFUV1htNlNnQVBvWVV1TkJZcXlocWYwRlEwWVd6VmhmSVFBQUFBJCQAAAAAAAAAAAEAAAAKxaCGusPA1tTDztIAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABZAMV8WQDFfU0; BAIDUID=5C8D78D64E6848E8E66D846DD5DFFE60:FG=1; fnizebra_b=P0lhrcN53vdMUS%2F6i6Jqke1DYnu1Bk7BKyn22Lr1OiSJcdkcuIE5QRexh80u3Q0CHAwYzANIhkgioe4D%2FK5Sa7%2BwWEa0CsRrSUcPM4pO%2FvjxvQAdf9qVcn5mRMjr6xQqsgdHPQGIyAFdR6CUMsb5axYXkySjX0%2BtBF7OsuEKruY%3D; SP_FW_VER=3.240.16; iadlist=49153; fontsize=1.10; H_WISE_SIDS=107314_110086_114551_127969_144966_154214_156286_156306_161278_162187_162203_162898_163115_163274_163390_163581_163808_163933_164043_164110_164164_164214_164216_164296_164692_164865_164880_164941_164992_165071_165135_165144_165327_165345_165591_165737_166055_166147_166180_166184_166255_166597_166599_166825_166987_167303_167388_167537_167571_167744_167771_167781_167926_167980_168034_168073_168215_168402; WISE_HIS_PM=1; BCLID=9140690592728723096; BDSFRCVID=JYKOJeCinR3Chr6eBYNMUON2YgKX8jRTH60oY2ODlwB_I7JoXeN5EG0P8x8g0KubrAb4ogKK0eOTHkCF_2uxOjjg8UtVJeC6EG0Ptf8g0f5; H_BDCLCKID_SF=tbCD_KK5JKD3HtJxKITHKb8jbeT22-usWH5i2hcH0bT_VCOJMbK-bfD4X4cPWMCHyCvihIn_Lfb1MCJvWj5cQ-AWLRnAtMTyyITw_l5TtUtWJKnTDMRh-RDF-GOyKMnitIT9-pno0hQrh459XP68bTkA5bjZKxtq3mkjbPbDfn02eCKu-n5jHjoWjajP; ST=0; BAIDULOC=13538033.981942_3634594.7065378_1000_289_1611659203826; ab_sr=1.0.0_MDg2OTViODUwYzI5ZDIwYmRjMmYyNjRhMmQyMWU0Y2JlMTRlOThhNDc5MzUyN2NjYjkzYzE4ZmYzYzQ1YjE3NmIwN2FiNTcxMDZjNjMwZTNiYTExMzhiNzQwMmY5ZmY3; x-logic-no=2", forHTTPHeaderField: "Cookie")
        manager.requestSerializer.setValue("https://m.baidu.com/s?tn=zbios&pu=sz%401320_480%2Ccuid%4045D34CA04432AE7FB8F806F7483DB2F06B58F8588FMMDBHJSRH%2Ccua%40828_1792_iphone_1.0.0.10_0%2Ccut%40iPhone11%2C8_12.1.2%2Cosname%40baiduboxapp%2Cosbranch%40i7%2Cctv%401%2Ccfrom%401005640h%2Ccsrc%40bdbox_tserch_txt%2Ccud%40REZCMkE2QjgtNkMzNy00MUEyLTgzRTEtQzMwNzk3RjhFQTRF&bd_page_type=1&word=%E5%BE%AE%E4%BF%A1%E5%B0%86%E6%8E%A8%E5%87%BA%E8%87%AA%E6%9C%89%E8%BE%93%E5%85%A5%E6%B3%95&sa=tkhr_3&ss=001001&network=1_0&from=1005640h&ant_ct=9%2BITzc9iee5%2F3Th%2BMIiUBqEXMBYcqM9RpZIkZRns%2Bxa8lKlxRUWJgmddGTCRGtet&rsv_sug4=8959&rsv_pq=16111291210279897629&oq=%E6%8B%9C%E7%99%BB%E5%90%AF%E7%A8%8B%E5%B0%B1%E8%81%8C%E5%91%8A%E5%88%AB%E6%B3%AA%E6%B4%92%E5%AE%B6%E4%B9%A1", forHTTPHeaderField: "Referer")
        
        var paras: [String : String] = [String : String]()
        paras["AFNetworking"] = "2.x"
        
        return paras
    }
    
    func stringWithDictionary(_ jsonDict : [String : AnyObject]) -> String {
        let data: Data = try! JSONSerialization.data(withJSONObject: jsonDict, options: JSONSerialization.WritingOptions.prettyPrinted)
        let jsonStr = String(data:data, encoding:String.Encoding.utf8)!
        
        print("jsonStr = \(jsonStr)")
        return jsonStr
    }
    
    func dictionaryWithString(_ jsonStr : String) -> [String : AnyObject] {
        let data: Data = jsonStr.data(using: String.Encoding.utf8)!
        
        let jsonDict: [String : AnyObject] = try! JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as! [String : AnyObject]
        return jsonDict
    }
}
