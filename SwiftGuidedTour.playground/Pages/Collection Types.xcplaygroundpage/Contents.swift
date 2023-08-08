//: [Previous](@previous)

//:**【集合可变性】**
//:* Swift提供数组（Array）、集合（Set）、字典（Dictionary）三种集合类型，均为值类型
//:* 如果创建一个Array、Set或Dictionary并且把它分配成一个变量，这个集合将会是可变的，这意味着我们可以在创建之后添加更多或移除已存在的数据项，或者改变集合中的数据项，如果我们把Array、Set或Dictionary分配成常量，那么它就是不可变的，它的大小和内容都不能被改变

//:**【创建数组】**
var someInts: [Int] = []
var anotherInts = [Int]()
var shoppingList = ["Eggs", "Milk"]

//:**【访问和修改数组】**
//:* 可以使用数组的只读属性count来获取数组中的数据项数量
print("The shopping list contains \(shoppingList.count) items.")
//:* 可以使用布尔属性isEmpty作为一个缩写形式去检查count属性是否为0
if shoppingList.isEmpty {
    print("The shopping list is empty.")
} else {
    print("The shopping list is not empty.")
}
//:* 可以使用append(_:)方法在数组后面添加新的数据项：
shoppingList.append("Flour")
//:* 可以使用加法赋值运算符（+=）直接在数组后面添加一个或多个拥有相同类型的数据项
shoppingList += ["Chocolate Spread", "Cheese", "Butter"]
//:* 可以使用下标语法来获取或修改数组中的数据项
var firstItem = shoppingList[0]
shoppingList[0] = "Six eggs"
//:* 可以利用下标来一次改变一系列数据值，即使新数据和原有数据的数量是不一样的
shoppingList[2...4] = ["Bananas", "Apples"]
//:* 不可以用下标访问的形式去在数组尾部添加新项
//:* 调用insert(_:at:)方法来在某个具体索引值之前添加数据项
shoppingList.insert("Maple Syrup", at: 0)
//:* 可以使用remove(at:)方法来移除数组中的某一项，这个方法把数组在特定索引值中存储的数据项移除并且返回这个被移除的数据项
let mapleSyrup = shoppingList.remove(at: 0)

//:**【遍历数组】**
//:* 可以使用for-in循环来遍历所有数组中的数据项
for item in shoppingList {
    print(item)
}
//:* 如果同时需要每个数据项的值和索引值，可以使用enumerated()方法来进行数组遍历，enumerated()返回一个由每一个数据项索引值和数据值组成的元组
for (index, value) in shoppingList.enumerated() {
    print("Item \(String(index + 1)): \(value)")
}

//:**【创建集合】**
//:* 一个类型为了存储在Set中，该类型必须是可哈希化的，即遵循Hashable协议，Swift的所有基本类型(比如String, Int, Double和Bool)默认都是可哈希化的
var letters: Set<Character> = []
var anotherLetters = Set<Character>()
var favoriteGenres: Set<String> = ["Rock", "Classical", "Hip hop"]

//:**【访问和修改集合】**
//:* 可以使用Set的只读属性count来获取Set中的数据项数量
print("I have \(favoriteGenres.count) favorite music genres.")
//:* 可以使用布尔属性isEmpty作为一个缩写形式去检查count属性是否为0
if favoriteGenres.isEmpty {
    print("As far as music goes, I'm not picky.")
} else {
    print("I have particular music preferences.")
}
//:* 可以通过调用Set的insert(_:)方法来添加一个新元素
favoriteGenres.insert("Jazz")
//:* 可以通过调用Set的remove(_:)方法去删除一个元素，如果该值是该Set的一个元素则删除该元素并且返回被删除的元素值，否则返回nil，另外， Set 中的所有元素可以通过它的removeAll()方法删除
if let removedGenre = favoriteGenres.remove("Rock") {
    print("\(removedGenre)? I'm over it.")
} else {
    print("I never much cared for that.")
}
//:* 可以使用contains(_:)方法去检查Set中是否包含一个特定的值
if favoriteGenres.contains("Funk") {
    print("I get up on the good foot.")
} else {
    print("It's too funky in here.")
}

//:**【遍历集合】**
//:* 可以在一个for-in循环中遍历一个Set中的所有值
for genre in favoriteGenres {
    print("\(genre)")
}

//:**【创建字典】**
//:* 一个字典的Key类型必须遵循Hashable协议
var oneDictionary: [Int: String] = [:]
var anotherDictionary = [Int: String]()
var airports: [String: String] = ["YYZ": "Toronto Pearson", "DUB": "Dublin"]

//:**【访问和修改字典】**
//:* 可以通过字典的只读属性count来获取某个字典的数据项数量
print("The dictionary of airports contains \(airports.count) items.")
//:* 使用布尔属性isEmpty作为一个缩写形式去检查count属性是否为0
if airports.isEmpty {
    print("The airports dictionary is empty.")
} else {
    print("The airports dictionary is not empty.")
}
//:* 可以在字典中使用下标语法添加和修改数据项
airports["LHR"] = "London"
airports["LHR"] = "London Heathrow"
//:* 可以使用下标语法在字典中检索特定键对应的值，因为有可能请求的键没有对应的值存在，字典的下标访问会返回对应值的类型的可选值
if let airportName = airports["DUB"] {
    print("The name of the airport is \(airportName).")
} else {
    print("That airport is not in the airports dictionary.")
}
//:* 可以使用下标语法来通过给某个键的对应值赋值为nil来从字典里移除一个键值对
airports["APL"] = "Apple Internation"
airports["APL"] = nil

//:**【遍历字典】**
//:* 可以使用for-in循环来遍历某个字典中的键值对，每一个字典中的数据项都以(key, value)元组形式返回
for (airportCode, airportName) in airports {
    print("\(airportCode): \(airportName)")
}
//:* 通过访问keys或者values属性，可以遍历字典的键或者值
for airportCode in airports.keys {
    print("Airport code: \(airportCode)")
}
for airportName in airports.values {
    print("Airport name: \(airportName)")
}

//: [Next](@next)
