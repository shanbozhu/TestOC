//: [Previous](@previous)

//:* 模块指的是独立的代码单元，框架或应用程序会作为一个独立的模块来构建和发布，在Swift中，一个模块可以使用import关键字导入另外一个模块

//:**【访问级别】**
//: 1) 开放访问（open）和公开访问（public）的实体既可以被同一模块的其他实体访问，也可以通过导入该模块被其他模块的实体访问
//: 2) 内部访问（internal）的实体可以被同一模块的其他实体访问，但是不能被其他模块的实体访问
//: 3) 文件私有访问（fileprivate）的实体只能被所定义的文件内部访问
//: 4) 私有访问（private）的实体只能在所定义的作用域内使
//:* 开放访问只作用于类类型和类的成员，它和公开访问的区别如下：
//: 1) 公开访问（public）的类，只能在它们定义的模块内部被继承，开放访问（open）的类，可以在它们定义的模块中被继承，也可以在引用它们的模块中被继承
//: 2) 公开访问（public）的类成员，只能在它们定义的模块内部的子类中重写，开放访问（open）的类成员，可以在它们定义的模块中子类中重写，也可以在引用它们的模块中的子类重写
//:* 如果不为代码中的实体显式指定访问级别，那么它们默认为internal级别（特殊情况除外）

//:**【自定义类型】**
//:* 一个类型的访问级别会影响到类型成员（属性、方法、构造器）的默认访问级别，如果将类型指定为私有或者文件私有级别，那么该类型的所有成员的默认访问级别也会变成私有或者文件私有级别，如果将类型指定为公开或者内部访问级别（或者不明确指定访问级别，而使用默认的内部访问级别），那么该类型的所有成员的默认访问级别将是内部访问
public class SomePublicClass { // 显式公开类
    public var somePublicProperty = 0 // 显式公开类成员
    var someInternalProperty = 0 // 隐式内部类成员
    fileprivate func someFilePrivateMethod() {} // 显式文件私有类成员
    private func somePrivateMethod() {} // 显式私有类成员
}
class SomeInternalClass { // 隐式内部类
    var someInternalProperty = 0 // 隐式内部类成员
    fileprivate func someFilePrivateMethod() {} // 显式文件私有类成员
    private func somePrivateMethod() {} // 显式私有类成员
}
fileprivate class SomeFilePrivateClass { // 显式文件私有类
    func someFilePrivateMethod() {} // 隐式文件私有类成员
    private func somePrivateMethod() {} // 显式私有类成员
}
private class SomePrivateClass { // 显式私有类
    func somePrivateMethod() {} // 隐式私有类成员
}

//:**【子类】**
//:* 子类的访问级别不得高于父类的访问级别
//:* 可以通过重写为继承来的类成员提供更高的访问级别
public class A {
    fileprivate func someMethod() {}
}
internal class B: A {
    override internal func someMethod() {}
}

//: [Next](@next)
