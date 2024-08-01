//
//  PBSwiftController.swift
//  TestOC
//
//  Created by Zhu,Shanbo on 2021/6/11.
//  Copyright © 2021 DaMaiIOS. All rights reserved.
//

import UIKit

class PBSwiftController: PBBaseController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 可选解包仅仅是为了获取里面的值
        // 警告和报错
        // 可选就是可空的意思。虽然是可空的，但对空解包会崩溃
        
        var myString: String? // 可选类型
        var myString1: String! // 可选类型，支持隐式解包
        var myString2: String // 字符串类型
        
        // 一、可选强制解包
        myString = "Hello"
        print(myString) // Optional("Hello")。直接打印可选类型会有警告
        print(myString!) // Hello
        
        let tmp: String = myString!
        print(tmp)
        
        if myString != nil {
            let tmp = myString!
            print(tmp)
        }
        if let tmp = myString { // 可选绑定。可选解包并绑定到变量
            print(tmp)
        }
        
        myString = nil
        print(myString) // nil
        //print(myString!) // 对nil解包，会崩溃。
        
        // 二、可选隐式解包
        myString1 = "world"
        print(myString1) // Optional("world")
        print(myString1!) // world
        
        let tmp1: String = myString1 // 等号左边是String类型，右边是Optional类型。等号左右两边变量数据类型匹配，所以右边其实存在隐式解包。
        print(tmp1)
        let tmp11: String = myString1! // !叹号可加可不加
        print(tmp11)
        
        if myString1 != nil {
            let tmp = myString1!
            print(tmp)
        }
        if let tmp = myString1 {
            print(tmp)
        }
        
        myString1 = nil
        print(myString1) // nil
        //print(myString1!) // 对nil解包，会崩溃。Fatal error: Unexpectedly found nil while unwrapping an Optional value: file TestOC/PBSwiftController.swift, line 36
        
        // 三、非nil字符串
        myString2 = "world"
        print(myString2) // world
        //myString2 = nil // 'nil' cannot be assigned to type 'String'
    }
    
    deinit {
        print("PBSwiftController对象被释放了")
    }
}
