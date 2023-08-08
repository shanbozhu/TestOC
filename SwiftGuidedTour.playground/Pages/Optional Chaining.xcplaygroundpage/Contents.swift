//: [Previous](@previous)

//:* 可选链式调用是一种可以在当前值可能为nil的可选值上请求和调用属性和方法的操作，如果可选值有值，那么调用就会成功，如果可选值是nil，那么调用将返回nil，多个调用可以连接在一起形成一个调用链，如果其中任何一个节点为nil，整个调用链都会失败，即返回nil
//:* 可选链式调用的返回结果与原本的返回结果具有相同的类型，但是被包装成了一个可选值，例如，使用可选链式调用访问属性，当可选链式调用成功时，如果属性原本的返回结果是Int类型，则会变为Int?类型
class Person {
    var residence: Residence?
}
class Residence {
    var numberOfRooms = 1
    func printNumberOfRooms() {
        print("The number of rooms is \(numberOfRooms)")
    }
}
let john = Person()
if let roomCount = john.residence?.numberOfRooms {
    print("John's residence has \(roomCount) room(s).")
} else {
    print("Unable to retrieve the number of rooms.")
}
//:* 可以通过可选链式调用来设置属性值
john.residence?.numberOfRooms = 2
//:* 可以通过可选链式调用来调用方法，并判断是否调用成功，即使这个方法没有返回值，没有返回值的方法具有隐式的返回类型Void，所以通过可选链式调用无返回值方法会得到Void?类型返回值，通过判断返回值是否为nil就可以知道调用是否成功
if john.residence?.printNumberOfRooms() != nil {
    print("It was possible to print the number of rooms.")
} else {
    print("It was not possible to print the number of rooms.")
}

//: [Next](@next)
