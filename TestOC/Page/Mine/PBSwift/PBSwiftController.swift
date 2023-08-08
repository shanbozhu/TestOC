//
//  PBSwiftController.swift
//  TestOC
//
//  Created by Zhu,Shanbo on 2021/6/11.
//  Copyright © 2021 DaMaiIOS. All rights reserved.
//

import UIKit

class Person {
    var residence: Residence?
}

class Residence {
    var numberOfRooms = 1
}

class PBSwiftController: PBBaseController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false // 取消自动调节ScrollView内边距
        
        let john = Person()

        // 链接可选residence?属性，如果residence存在则取回numberOfRooms的值
        if let roomCount = john.residence?.numberOfRooms {
            print("John 的房间号为 \(roomCount)。")
        } else {
            print("不能查看房间号")
        }
    }
    
    deinit {
        print("PBSwiftController对象被释放了")
    }
}
