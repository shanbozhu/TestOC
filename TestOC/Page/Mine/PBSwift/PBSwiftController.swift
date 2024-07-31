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
        
        var myString: String? // 可选类型
        var myString1: String! // 可选类型
        var myString2: String // 字符串类型
        
        // 可选强制解包
        myString = "Hello"
        print(myString) // Optional("Hello")
        print(myString!) // Hello
        myString = nil
        print(myString) // nil
        //print(myString!) // 对nil解包，会崩溃。
        if myString != nil {
            let tmp = myString!
            print(tmp)
        }
        if let tmp = myString {
            print(tmp)
        }
        myString = "hello"
        let tmp: String = myString!
        print(tmp)
        
        // 可选隐式解包
        myString1 = "world"
        print(myString1) // Optional("world")
        print(myString1!) // world
        myString1 = nil
        print(myString1) // nil
        //print(myString1!) // 对nil解包，会崩溃。Fatal error: Unexpectedly found nil while unwrapping an Optional value: file TestOC/PBSwiftController.swift, line 36
        if myString1 != nil {
            let tmp = myString1!
            print(tmp)
        }
        if let tmp = myString1 {
            print(tmp)
        }
        myString1 = "world"
        let tmp1: String = myString1
        print(tmp1)
        let tmp11: String = myString1! // !叹号可加可不加
        print(tmp11)
        
        // 非nil字符串
        myString2 = "world"
        print(myString2) // world
        //myString2 = nil // 'nil' cannot be assigned to type 'String'
    }
    
    deinit {
        print("PBSwiftController对象被释放了")
    }
}
