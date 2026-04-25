//: [Previous](@previous)

//:**【空字符串】**
var emptyString = ""
var anotherEmptyString = String()
//:* 可以通过检查Bool类型的isEmpty属性来判断字符串是否为空
if emptyString.isEmpty {
    print("Nothing to see here")
}

//:**【字符串可变性】**
var variableString = "Horse"
variableString += " and carriage"
//let constantString = "Highlander"
//constantString += " and another Highlander"
//:* Swift的String类型是值类型，当进行常量、变量赋值操作，或在函数/方法中传递时，会进行值拷贝
//:* 在Objective-C中，需要通过选择两个不同的类(NSString 和 NSMutableString)来指定字符串是否可以被修改
import Foundation
let oneNSString: NSString = "Horse  and carriage"
let anotherNSString = "Horse  and carriage" as NSString

//:**【字符】**
let exclamationMark: Character = "!"
//:* 可以通过for-in循环遍历字符串来获取每一个字符的值
for character in "Dog" {
    print(character)
}
//:* 字符串可以通过传递一个值类型为Character的数组作为自变量来初始化
let catCharacters: [Character] = ["C", "a", "t", "!", "?"]
let catString = String(catCharacters)

//:**【连接字符串和字符】**
//:* 字符串可以通过加法运算符（+）连接在一起创建一个新的字符串
let string1 = "hello"
let string2 = " there"
var welcomeString = string1 + string2
//:* 可以用append()方法将一个字符附加到一个字符串变量的尾部
let exclamationCharacter: Character = "!"
welcomeString.append(exclamationCharacter)

//:**【字符串插值】**
//:* 字符串插值是一种构建新字符串的方式，可以在其中包含常量、变量、字面量和表达式，插入的字符串字面量的每一项都在以反斜线为前缀的圆括号中
let apples = 3
let oranges = 5
let appleSummary = "I have \(apples) apples."
let fruitSummary = "I have \(apples + oranges) pieces of fruit."

//:**【字符串编码】**
//:* 每一个Swift的Character类型代表一个可扩展的字形群，一个可扩展的字形群是一个或多个可生成人类可读的字符Unicode标量的有序排列
//:* NSString的length属性是利用UTF-16表示的十六位代码单元数字，而不是Unicode可扩展的字符群
import Foundation
let testNSString: NSString = "😃"
let countNSString = testNSString.length
let testString: String = "😃"
let countString = testString.count

//:**【访问和修改字符串】**
//:* 每一个String值都有一个关联的索引类型String.Index，它对应着字符串中的每一个Character的位置，Swift的字符串不能用整数做索引
//:* 使用startIndex属性可以获取一个String的第一个Character的索引，使用endIndex属性可以获取最后一个Character的后一个位置的索引，因此，endIndex属性不能作为一个字符串的有效下标，如果String 是空串，startIndex 和endIndex 是相等的
//:* 通过调用String的index(before:)或index(after:)方法，可以得到前面或后面的一个索引，通过调用index(_:offsetBy:)方法来获取对应偏移量的索引
let greeting = "Guten Tag!"
greeting[greeting.startIndex]
greeting[greeting.index(before: greeting.endIndex)]
greeting[greeting.index(after: greeting.startIndex)]
let index = greeting.index(greeting.startIndex, offsetBy: 7)
greeting[index]
//:* 试图获取越界索引对应的Character，将引发一个运行时错误
//:* 调用insert(_:at:)方法可以在一个字符串的指定索引插入一个字符，调用insert(contentsOf:at:)方法可以在一个字符串的指定索引插入一个段字符串
var welcome = "hello"
welcome.insert("!", at: welcome.endIndex)  // welcome变量现在等于"hello!"
welcome.insert(contentsOf:" there", at: welcome.index(before: welcome.endIndex))  // welcome 变量现在等于 "hello there!"
//:* 调用remove(at:)方法可以在一个字符串的指定索引删除一个字符，调用removeSubrange(_:)方法可以在一个字符串的指定索引删除一个子字符串
welcome.remove(at: welcome.index(before: welcome.endIndex))  // welcome 现在等于 "hello there"
let range = welcome.index(welcome.endIndex, offsetBy: -6)..<welcome.endIndex
welcome.removeSubrange(range)  // welcome 现在等于 "hello"

//:**【比较字符串】**
//:* 字符和字符串可以用等于操作符(==)和不等于操作符(!=)进行比较
let quotation = "We're a lot alike, you and I."
let sameQuotation = "We're a lot alike, you and I."
if quotation == sameQuotation {
    print("These two strings are considered equal")
}
//:* 通过调用字符串的hasPrefix(_:)或hasSuffix(_:)方法来检查字符串是否拥有特定前缀或后缀，两个方法均接收一个String类型的参数，并返回一个布尔值

//: [Next](@next)
