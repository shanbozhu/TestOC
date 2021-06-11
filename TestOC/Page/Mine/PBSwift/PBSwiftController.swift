//
//  PBSwiftController.swift
//  TestOC
//
//  Created by Zhu,Shanbo on 2021/6/11.
//  Copyright © 2021 DaMaiIOS. All rights reserved.
//

import UIKit

class PBSwiftController: UIViewController {
    func requestData(_ sinceId: Int, status: Int) {
        let requestUrl = "https://m.baidu.com/suggest?empty_field=10000&ctl=his&action=list&cfrom=1099a&ds_lv=7&ds_stc=0.7740&from=1099a&matrixstyle=0&network=1_0&osbranch=i0&osname=baiduboxapp&puid=_u2Kt_OQv8SlmqqqB&service=bdbox&sid=6736_12719-1047041_2-7485_15785-5670_8749-1041509_3-7736_17508-1047666_2-5743_8970-1047570_2-7803_17165-7781_17082-7115_14210-7528_15985-7395_15371-7683_16630-7107_14184-7152_14366-6289_11046-1047113_2-6608_12202-7372_15284-6495_13506-6446_11633-1042091_2-7801_17158-1047642_2-7154_14378-1047327_2-7696_16684-7352_15190-6613_12213-7748_16933-7373_15287-1046962_1-6828_13013-1047748_4-1047780_1-7739_16890-1047314_2-7348_15176-1047891_2-5684_8793-5942_9687-7005_13800-7592_16243-6035_10148-7588_16229-6616_12228-7845_17387-1047351_2-1047394_3-6766_12806-1042957_1-7320_15053-7851_17412-6959_13582-6728_12698-1047441_1-7397_15374-7061_14009-5932_9637-1047149_3-1042931_1-1047683_2-5993_9983-7859_17455-7907_17692-7848_17394-1047340_2-6598_12169-1047408_1-5191_7787-6411_11528-1046595_4-1047539_1-7416_15447-6589_12139-7406_15400-6887_13272-7714_16739-1047733_3-7161_14403-6369_11345-1046559_1-1047289_2-6436_11607-7713_17207-7167_14420-1047587_6-6136_10522-6776_12836-7546_17298-7530_15994-7741_16896-7721_16768-6414_11535-7824_17278-1047778_4-5651_9550-5660_8717-7419_15454-7723_17479-6685_12531-1046871_3-5153_7043-7586_16225-1047274_7-7126_14274-5187_7154-7327_15084-7164_14410-6993_13758-1047646_1-1047266_5-7609_16298-5302_7554-7690_16649-1047868_3-7687_16642-5600_8525-5177_7114-7838_17346-6484_11783-7600_16263-6694_14192-6373_11358-1047129_3-7699_16693-6302_11094-1047060_1-7413_15434-7011_13816-7752_16954-7503_15865-7807_17180-1047554_1-7418_15588-1047829_2-6490_11802-7636_16440-6840_13041-1043807_2-7874_17526-5356_7706-1047768_1-7718_16752-7378_15307-1047816_2-6434_11603-5784_10147-7893_17634-7892_17625-1047652_2-7411_15427-7141_14320-7038_14441-6720_12668-1047523_2-1047546_4-5760_9013-7334_15117-7694_16676-7788_17111-1047825_1-7340_15143-7873_17520-5994_9995-6782_12864-5253_7382-7280_14873-1047835_3-7051_13962-1047401_1-7215_14602-7732_16817-5629_8629-6426_11588-7836_17336-6630_12291-6128_10484-7765_17010-1047746_1-6217_10807-7146_14347-1047514_2-5941_9680-6659_12433-7020_13854-7157_14389-1047050_3-7521_15932-7290_14936-1047413_3-5605_8538-6928_13416-6801_12917-7498_15831-7913_17710-7660_16940-1047491_4-1047352_2-7575_16177-6342_11250-7448_15618-1047407_1-5159_7064-7257_14780-5358_7712-6545_12962-7266_14817-7410_15426-1047641_1-6256_10950-7657_16525-6944_13511-6922_13397-5465_8048-7258_14783-7318_15047-1047724_1-6634_12533-1047225_2-6306_11119-7370_15278-7026_14423-7075_14063-6654_12416-7128_14279-7085_14101-1047235_4-7462_16268-7423_15472-1047494_1-1047805_6-7054_13968-5396_7835-1047706_2-6857_14221-7250_15205-5188_7160-1047250_5-1047525_6-1047761_1-6466_11716-1047446_1-7735_16852-1042999_1-1047234_1-5815_9215-6732_12709-7013_13827-6796_12903-7553_16096-7712_16728-1047037_1-6007_10508-7420_15456-6412_11530-1047715_1-7116_14222-7084_14098-6715_12642-7473_15740-6842_13046-1047702_1-6396_11472-6896_13297-6145_10553-5280_7494-7655_16521-6958_13579-6142_10557-7331_15112-5500_8196&st=0&ua=828_1792_iphone_12.17.0.1_0&uid=45D34CA04432AE7FB8F806F7483DB2F06B58F8588FMMDBHJSRH&ut=iPhone11%2C8_12.1.2&zid=MowzQoEcY-nekbrCSe81hD2bEiGt5Q1itnKJo6S65D3FjREtnYW0pP9JS34FZAoGMXNM_cO7KynfHotkJEntNbw"
        
        let manager: AFHTTPRequestOperationManager = AFHTTPRequestOperationManager()
        manager.requestSerializer = AFHTTPRequestSerializer()
        manager.responseSerializer = AFHTTPResponseSerializer()
        
        var paras = self.requestHeaderAndBody(manager: manager)
        paras["sortTime"] = String(sinceId)
        
        weak var weakSelf = self
        manager.post(requestUrl, parameters: paras, success: { (operation: AFHTTPRequestOperation?, responseObject: Any?) in
            let jsonDict: [String : AnyObject] = try! JSONSerialization.jsonObject(with: responseObject as! Data, options: JSONSerialization.ReadingOptions.mutableContainers) as! [String : AnyObject]
            
            weakSelf!.stringWithDictionary(jsonDict)
            
        }) { (operation: AFHTTPRequestOperation?, error :Error?) in
            print(error!)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        let lab: UILabel = UILabel()
        self.view.addSubview(lab)
        lab.frame = CGRect(x: 80, y: 100, width: 200, height: 0)
        lab.numberOfLines = 0
        lab.text = "我是用swift写的页面,发送了一个网络请求"
        lab.sizeToFit()
        lab.layer.borderColor = UIColor.red.cgColor
        lab.layer.borderWidth = 1
        
        self.requestData(0, status: 0)
    }
    
    deinit {
        print("PBTestOneController对象被释放了")
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
