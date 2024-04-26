//
//  PBRuntimeEightController.m
//  TestOC
//
//  Created by shanbo on 2024/4/25.
//  Copyright © 2024 DaMaiIOS. All rights reserved.
//

#import "PBRuntimeEightController.h"
#import "PBRuntimeEightController+Debug.h"

// 参考文档:
// ios动态添加属性的几种方法 https://blog.csdn.net/shengyumojian/article/details/44919695
// Objective-C Runtime https://yulingtianxia.com/blog/2014/11/05/objective-c-runtime/#objc-property-t

@interface PBRuntimeEightController ()

@property (nonatomic, copy) NSString *testName;
@property (nonatomic, strong) NSArray *testAge;
@property (nonatomic, assign) NSInteger testHeight;

@end

@implementation PBRuntimeEightController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    {
        {
            // 打印指定属性的属性
            objc_property_t nameProperty = class_getProperty(self.class, "testName");
            unsigned int count = 0;
            objc_property_attribute_t *attributeList = property_copyAttributeList(nameProperty, &count);
            for (int i = 0; i < count; i++) {
                objc_property_attribute_t t= attributeList[i];
                NSLog(@"name = %s, value = %s", t.name, t.value);
            }
            
            // 打印指定属性的属性
            nameProperty = class_getProperty(self.class, "testAge");
            count = 0;
            attributeList = property_copyAttributeList(nameProperty, &count);
            for (int i = 0; i < count; i++) {
                objc_property_attribute_t t= attributeList[i];
                NSLog(@"name = %s, value = %s", t.name, t.value);
            }
            
            // 打印指定属性的属性
            nameProperty = class_getProperty(self.class, "testHeight");
            count = 0;
            attributeList = property_copyAttributeList(nameProperty, &count);
            for (int i = 0; i < count; i++) {
                objc_property_attribute_t t= attributeList[i];
                NSLog(@"name = %s, value = %s", t.name, t.value);
            }
        }
        
        {
            // 打印类的所有的属性的属性
            unsigned int count = 0;
            objc_property_t *list = class_copyPropertyList(self.class, &count);
            for (int i = 0; i < count; i++) {
                objc_property_t t = list[i];
                NSLog(@"name = %s, att = %s", property_getName(t), property_getAttributes(t));
            }
        }
    }
    
    {
        // 方案一
        
        // 分类中添加属性
        self.name = @"jack";
        self.age = 19;
        NSLog(@"self.name = %@, self.age = %ld", self.name, self.age);
    }
    
    {
        // 方案二
        [self performSelector:@selector(setHeight:) withObject:@[@"1", @"2", @{@"3" : @"4"}]];
        NSLog(@"height = %@", [self performSelector:@selector(height)]);
    }
}

@end
