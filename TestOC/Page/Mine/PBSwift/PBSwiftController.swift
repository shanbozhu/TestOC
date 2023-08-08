//
//  PBSwiftController.swift
//  TestOC
//
//  Created by Zhu,Shanbo on 2021/6/11.
//  Copyright © 2021 DaMaiIOS. All rights reserved.
//

import UIKit

class PBSwiftController: PBBaseController {
    
    var myString:String?
    var myString1:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 可选强制解析
        myString = "Hello, Swift!"
        print(myString)
        print(myString!)
        
        // 可选自动解析
        print(myString1)
    }
    
    deinit {
        print("PBSwiftController对象被释放了")
    }
}
