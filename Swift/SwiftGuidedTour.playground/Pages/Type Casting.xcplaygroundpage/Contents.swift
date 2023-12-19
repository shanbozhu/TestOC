//: [Previous](@previous)

//:* 可以将类型转换用在类和子类的层次结构上，检查特定类实例的类型并且转换这个类实例的类型成为这个层次结构中的其他类型
class MediaItem {
    var name: String
    init(name: String) {
        self.name = name
    }
}
class Movie: MediaItem {
    var director: String
    init(name: String, director: String) {
        self.director = director
        super.init(name: name)
    }
}
class Song: MediaItem {
    var artist: String
    init(name: String, artist: String) {
        self.artist = artist
        super.init(name: name)
    }
}
//:* 用类型检查操作符（is）来检查一个实例是否属于特定子类型，若实例属于那个子类型，类型检查操作符返回true，否则返回false
let library = [
    Movie(name: "Casablanca", director: "Michael Curtiz"),
    Song(name: "Blue Suede Shoes", artist: "Elvis Presley"),
    Movie(name: "Citizen Kane", director: "Orson Welles"),
    Song(name: "The One And Only", artist: "Chesney Hawkes"),
    Song(name: "Never Gonna Give You Up", artist: "Rick Astley")
]  // [MediaItem]
var movieCount = 0
var songCount = 0
for item in library {
    if item is Movie {
        movieCount += 1
    } else if item is Song {
        songCount += 1
    }
}
print("Media library contains \(movieCount) movies and \(songCount) songs")
//:* 某类型的常量或变量可能实际上属于一个子类，在这种情况下，可以尝试向下转到它的子类型，用类型转换操作符（as?或as!），条件形式as?返回一个试图向下转成的类型的可选值，强制形式as!把试图向下转型和强制解包转换结果结合为一个操作
for item in library {
    if let movie = item as? Movie {
        print("Movie: '\(movie.name)', dir. \(movie.director)")
    } else if let song = item as? Song {
        print("Song: '\(song.name)', by \(song.artist)")
    }
}
//:* 桥接类型之间可以使用as转换，例如String和NSString
import Foundation
let name = "Steve Jobs"
let firstName = (name as NSString).substring(to: 5)
//:* Any可以表示任何类型，包括函数类型，AnyObject可以表示任何类类型的实例
var things = [Any]()
things.append(0)
things.append(0.0)
things.append(42)
things.append(3.14159)
things.append("hello")
things.append((3.0, 5.0))
things.append(Movie(name: "Ghostbusters", director: "Ivan Reitman"))
things.append({ (name: String) -> String in "Hello, \(name)" })

//: [Next](@next)
