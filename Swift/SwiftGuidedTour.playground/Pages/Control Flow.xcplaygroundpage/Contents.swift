//: [Previous](@previous)

//:**【For-In循环】**
for index in 1...5 {
    print("\(index) times 5 is \(index * 5)")
}

//:**【While循环】**
//:* while循环，每次在循环开始时计算条件是否符合
/*
while condition {
    statements
}
 */
//:* repeat-while循环，每次在循环结束时计算条件是否符合
/*
repeat {
    statements
} while condition
 */

//:**【If条件语句】**

//:**【Swith条件语句】**
let someCharacter: Character = "z"
switch someCharacter {
case "a":
    print("The first letter of the alphabet")
case "z":
    print("The last letter of the alphabet")
default:
    print("Some other character")
}
//:* switch语句必须是完备的，也就是说，每一个可能的值都必须至少有一个case分支与之对应，在某些不可能涵盖所有值的情况下，可以使用默认（default）分支来涵盖其它所有没有对应的值，这个默认分支必须在switch语句的最后面
//:* switch语句不存在隐式贯穿，当匹配的case分支中的代码执行完毕后，程序会终止switch语句，而不会继续执行下一个case分支，如果想要显式贯穿case分支，使用fallthrough语句
//:* 每一个case分支都必须包含至少一条语句
//let anotherCharacter: Character = "a"
//switch anotherCharacter {
//case "a":  // 无效，这个分支下面没有语句
//case "A":
//    print("The letter A")
//default:
//    print("Not the letter A")
//}
//:* 为了让单个case同时匹配多个值，可以将多个值组合成一个复合匹配，并且用逗号分开
let anotherCharacter: Character = "a"
switch anotherCharacter {
case "a", "A":
    print("The letter A")
default:
    print("Not the letter A")
}

//:**【提前退出】**
//:* 像if语句一样，guard的执行取决于一个表达式的布尔值，可以使用guard语句来要求条件必须为真时，以执行guard语句后的代码，一个guard语句总是有一个else从句，如果条件不为真则执行else从句中的代码
func greet(person: [String: String]) {
    guard let name = person["name"] else {
        return
    }
    print("Hello \(name)")
    guard let location = person["location"] else {
        print("I hope the weather is nice near you.")
        return
    }
    print("I hope the weather is nice in \(location).")
}


//: [Next](@next)
