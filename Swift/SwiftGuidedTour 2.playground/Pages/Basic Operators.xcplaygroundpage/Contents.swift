//: [Previous](@previous)

//:**【赋值运算符】**
//:* 与C和Objective-C不同，Swift的赋值操作（=、 +=、-=等）不返回任何值
//if x = y {
//}

//:**【算术运算符】**
//:* Swift二元算术运算符包括  +  -  *  /  %  一元算术运算符包括  +  -
//:* 与C和Objective-C不同，Swift默认情况下不允许在数值运算中出现溢出情况，使用溢出运算符来实现溢出运算
//let sum: Int8 = 103 + 89
let sum: Int8 = 103 &+ 89
//:* 加法运算符可用于String的拼接
"hello, " + "world"

//:**【比较运算符】**
//:* Swift比较运算符  ==  !=  >  >=  <  <=
//:* 当元组中的值可以比较时，可以使用比较运算符来比较元组的大小，比较元组大小会按照从左到右、逐值比较的方式，直到发现有两个值不等时停止，如果所有的值都相等，那么这一对元组我们就称它们是相等的
(1, "zebra") < (2, "apple") // true，因为 1 小于 2
(3, "apple") < (3, "bird") // true，因为 3 等于 3，但是 apple 小于 bird
(4, "dog") == (4, "dog") // true，因为 4 等于 4，dog 等于 dog

//:**【三目运算符】**
let contentHeight = 40
let hasHeader = true
let rowHeight = contentHeight + (hasHeader ? 50 : 20)

//:**【空合运算符】**
//:* 空合运算符（a ?? b）将对可选类型a进行空判断，如果a包含一个值就进行解封，否则就返回一个默认值b，表达式a必须是可选 类型，默认值b的类型必须要和a存储值的类型保持一致，空合运算符是对以下代码的简短表达方法：a != nil ? a! : b
let defaultColorName = "red"
var userDefinedColorName: String?  // 默认值为 nil
var colorNameToUse = userDefinedColorName ?? defaultColorName
//:* 如果a 为非空值，那么值b 将不会被计算，即所谓的短路计算

//:**【区间运算符】**
//:* 闭区间运算符（a...b）定义一个包含从a到b（包括a和b）的所有值的区间，a的值不能超过b
for index in 1...5 {
    print("\(index) * 5 = \(index * 5)")
}
//:* 半开区间运算符（a..<b）定义一个从a到b但不包括b的区间
let names = ["Anna", "Alex", "Brian", "Jack"]
let count = names.count
for i in 0..<count {
    print("第 \(i + 1) 个人叫 \(names[i])")
}

//:**【逻辑运算符】**
//:* Swift逻辑运算符包括  &&  ||  ！ ，逻辑运算符的操作对象是逻辑布尔值
//:* &&和||存在短路计算

//: [Next](@next)
