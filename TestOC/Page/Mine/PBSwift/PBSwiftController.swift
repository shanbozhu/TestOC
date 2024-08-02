//
//  PBSwiftController.swift
//  TestOC
//
//  Created by Zhu,Shanbo on 2021/6/11.
//  Copyright © 2021 DaMaiIOS. All rights reserved.
//

import UIKit

class PBSwiftController: PBBaseController {
    
    var button: UIButton? = UIButton() // 可选类型
    var button1: UIButton! = UIButton() // 可选类型，支持隐式解包
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 警告和报错
        
        // 可选解包仅仅是为了获取里面的值，解包的目的是为了使用里面的值。
        // 可选就是可空的意思。虽然是可空的，但对空解包会崩溃
        
        var myString: String? // 可选类型
        var myString1: String! // 可选类型，支持隐式解包
        var myString2: String // 字符串类型
        
        // 一、可选强制解包
        myString = "Hello"
        print(myString) // Optional("Hello")。直接打印可选类型会有警告。Expression implicitly coerced from 'String?' to 'Any'
        print(myString!) // Hello
        
        //print(myString?) // '?' must be followed by a call, member lookup, or subscript
        //print(myString.count) // Value of optional type 'String?' must be unwrapped to refer to member 'count' of wrapped base type 'String'
        print(myString!.count)
        print(myString?.count ?? 0) // 可选链式调用，myString可为空
        
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
        print(myString) // nil。Expression implicitly coerced from 'String?' to 'Any'
        //print(myString!) // 对nil解包，会崩溃。
        
        // 二、可选隐式解包
        myString1 = "world"
        print(myString1) // Optional("world")。Coercion of implicitly unwrappable value of type 'String?' to 'Any' does not unwrap optional
        print(myString1!) // world
        
        let tmp1: String = myString1 // 等号左边是String类型，右边是Optional类型。等号左右两边变量数据类型匹配，所以右边其实存在隐式解包。
        print(tmp1)
        let tmp11: String = myString1! // !叹号可写可不写
        print(tmp11)
        
        if myString1 != nil {
            let tmp = myString1!
            print(tmp)
        }
        if let tmp = myString1 {
            print(tmp)
        }
        
        myString1 = nil
        print(myString1) // nil。Coercion of implicitly unwrappable value of type 'String?' to 'Any' does not unwrap optional
        //print(myString1!) // 对nil解包，会崩溃。Fatal error: Unexpectedly found nil while unwrapping an Optional value: file TestOC/PBSwiftController.swift, line 36
        
        // 三、非nil字符串
        myString2 = "world"
        print(myString2) // world
        //myString2 = nil // 'nil' cannot be assigned to type 'String'
        
        // 四
        let num: Int! = 13
        let num2: Int! = 14
        let num3 = num + num2 // 可选隐式解包，!叹号可写可不写。
        print(num3)
        let num4 = num! + num2! // 可选隐式解包，!叹号可写可不写。
        print(num4)
        
        let num1: Int? = 13
        let num12: Int? = 14
        let num13 = num1! + num12! // 可选强制解包
        print(num13)
        
        // 五、可选链式调用
        print(self.button) // Expression implicitly coerced from 'UIButton?' to 'Any'
        print(self.button?.frame.size.height ?? 0) // 可选链式调用。在不知道button是否为空的情况下推荐使用可选链式调用。button可空的，当button为nil时，执行frame无效果，整体调用就返回0
        print(self.button!.frame.size.height) // 强制解包。必须确保button1非nil，否则，对nil解包会崩溃
        
        print(self.button1) // Coercion of implicitly unwrappable value of type 'UIButton?' to 'Any' does not unwrap optional
        print(self.button1.frame.size.height) // 可选隐式解包
        print(self.button1!.frame.size.height) // 可选隐式解包，!叹号可写可不写
    }
    
    deinit {
        print("PBSwiftController对象被释放了")
    }
}
