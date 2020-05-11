//
//  PBCopy.m
//  TestOC
//
//  Created by DaMaiIOS on 2017/12/5.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import "PBCopy.h"

@implementation PBCopy

- (id)copyWithZone:(NSZone *)zone {
    PBCopy *testList = [[self.class allocWithZone:zone]init];

    testList.name = self.name;

    return testList;
}

- (id)mutableCopyWithZone:(NSZone *)zone {
    PBCopy *testList = [[self.class allocWithZone:zone]init];
    
    testList.name = self.name;
    
    return testList;
}

//- (id)copyWithZone:(NSZone *)zone {
//    return self;
//}

@end
