import UIKit

// Protocol Sysntax & Property Requirements
protocol SomeProtocol {
    // protocol define goes here
    var mustBeSettable: Int { get set }
    var doesNotNeedToBeSettable: Int { get }
    static func someTypeMethod() // Method requirement
    init() // Initializer Requirements
}

protocol FirstProtocol {
    // protocol define goes here
}

protocol AnotherProtocol {
    // protocol define goes here
    static var someTypeProperty: Int { get set }
}
//struct SomeStructure: FirstProtocol, AnotherProtocol {
//    // structure difinition goes here
//}

class SomeSuperclass {
    // class definition goes here
}
//class SomeClass: SomeSuperclass, FirstProtocol,AnotherProtocol {
//    // class definition goes here
//}


protocol FullyNamed {
    var fullName: String { get }
}

struct Person: FullyNamed {
    var fullName: String
}

let john = Person(fullName: "John Appleseed")
print("\(john)")

class StarShip: FullyNamed {
    var prefix: String?
    var name: String
    init(name: String, prefix: String? = nil) {
        self.name = name
        self.prefix = prefix
    }
    
    var fullName: String {
        return (prefix != nil ? prefix! + " ":"") + name
    }
}

var ncc1701 = StarShip(name: "Enterprise", prefix: "USS")
print("\(ncc1701.fullName)")

// Method Requirements
protocol RandomNumberGenerator {
    func random() -> Double
}

class LinearCongruentialGenerator: RandomNumberGenerator {
    var lastRandom = 42.0
    let m = 139968.0
    let a = 3877.0
    let c = 29573.0
    func random() -> Double {
        lastRandom = ((lastRandom * a + c).truncatingRemainder(dividingBy: m))
        return lastRandom / m
    }
}
let generator = LinearCongruentialGenerator()
print("Here's a random number: \(generator.random())")
print("And another one: \(generator.random())")

// Mutating Method Requirements
protocol Togglable {
    mutating func toggle()
}

enum OnOffSwitch: Togglable {
    case off, on
    mutating func toggle() {
        switch self {
        case .off:
            self = .on
        case .on:
            self = .off
            
        }
    }
}
var lightSwitch = OnOffSwitch.off
lightSwitch.toggle()

// Initializer Requirements
class SomeSuperClass {
    init() {
        // initializer implementation goes here
    }
}

//class SomeSubClass: SomeSuperClass, SomeProtocol {
//    // "required" from SomeProtocol conformance;
//    // "override" from SomeSuperClass
//    required override init() {
//        // initializer implementation goes here
//    }
//}

// Protocol as Type
class Dice {
    let sides: Int
    let generator: RandomNumberGenerator
    init(sides: Int, generator: RandomNumberGenerator) {
        self.sides = sides
        self.generator = generator
    }
    func roll() -> Int {
        return Int(generator.random() * Double(sides)) + 1
    }
}

var d6 = Dice(sides: 6, generator: LinearCongruentialGenerator())
for _ in 1...5 {
    print("Random dice roll is \(d6.roll())")
}

// Delegation
protocol DiceGame {
    var dice: Dice { get }
    func play()
}

protocol DiceGameDelegate: AnyObject {
    func gameDidStart(_ game: DiceGame)
    func game(_ game: DiceGame, didStartNewWithDiceRoll diceRoll: Int)
    func gameDidEnd(_ game: DiceGame)
}

class SnakesAndLadders: DiceGame {
    let finalSquare = 25
    let dice = Dice(sides: 6, generator: LinearCongruentialGenerator())
    var square = 0
    var board: [Int]
    init() {
        board = Array(repeating: 0, count: finalSquare + 1)
        board[03] = +08; board[06] = +11; board[09] = +09; board[10] = +02
        board[14] = -10; board[19] = -11; board[22] = -02; board[24] = -08
    }
    
    weak var delegte: DiceGameDelegate?
    func play() {
        square = 0
        delegte?.gameDidStart(self)
        gameLoop: while square != finalSquare {
            
            let diceRoll = dice.roll()
            delegte?.game(self, didStartNewWithDiceRoll: diceRoll)
            
            switch square + diceRoll {
            case finalSquare:
                break gameLoop
            case let newSquare where newSquare > finalSquare:
                continue gameLoop
            default:
                square += diceRoll
                square += board[square]
            }
        }
        delegte?.gameDidEnd(self)
    }
}

class DiceGameTracker: DiceGameDelegate {
    var numberOfTurns = 0
    func gameDidStart(_ game: DiceGame) {
        numberOfTurns = 0
        if game is SnakesAndLadders {
            print("Started a new game of Snakes and Ladders")
            print("The game is using a \(game.dice.sides) - sided dice")
        }
    }
    func game(_ game: DiceGame, didStartNewWithDiceRoll diceRoll: Int) {
        numberOfTurns += 1
        print("Rolled a \(diceRoll)")
    }
    func gameDidEnd(_ game: DiceGame) {
        print("The game lasted for \(numberOfTurns) turns")
    }
}

let tracker = DiceGameTracker()
let game = SnakesAndLadders()
game.delegte = tracker
game.play()

// Adding Protocol COnformance with an Extension
protocol TextRepresentable {
    var textualDescription: String { get }
}

extension Dice: TextRepresentable {
    var textualDescription: String {
        return "A \(sides) - sided dice"
    }
}
let d12 = Dice(sides: 12, generator: LinearCongruentialGenerator())
print(d12.textualDescription)

extension SnakesAndLadders: TextRepresentable {
    var textualDescription: String {
        return "A game of Snakes and Ladders with \(finalSquare) squares"
    }
}
print(game.textualDescription)


// Conditionally Conforming to a Protocol
extension Array: TextRepresentable where Element: TextRepresentable {
    var textualDescription: String {
        let itemsAsText = self.map { $0.textualDescription }
        return "[" + itemsAsText.joined(separator: ", ") + "]"
    }
}
var myDice = [d6, d12]
print(myDice.textualDescription)

// Declaring Protocol Adoption with an Extension
struct Hamster {
    var name: String
    var textualDescription: String {
        return "A hamster named \(name)"
    }
}
extension Hamster:TextRepresentable {}
let simonTheHamster = Hamster(name: "Simon")
let somethingTextRepresentable: TextRepresentable = simonTheHamster
print(somethingTextRepresentable.textualDescription)
var text: [TextRepresentable] = [simonTheHamster, d6]

// Collections of Protocol Types
let things: [TextRepresentable] = [game, d12, simonTheHamster]
for thing in things {
    print("thing: \(thing.textualDescription)")
}

// Protocol Inheritance
protocol InheritingProtocol: SomeProtocol, AnotherProtocol {
    // protocol definition goes here
}


protocol PrettyTextRepresentable: TextRepresentable {
    var prettyTextualDescription: String { get }
}

extension SnakesAndLadders: PrettyTextRepresentable {
    var prettyTextualDescription: String {
        var output = textualDescription + ":\n"
        for index in 1...finalSquare {
            switch board[index] {
            case let ladder where ladder > 0:
                output += "▲ "
            case let snake where snake < 0:
                output += "▼ "
            default:
                output += "○ "
            }
        }
        return output
    }
}
print(game.prettyTextualDescription)

// Class-Only Protocols
//protocol SomeClassOnlyProtocol: AnyObject, SomeInheritedProtocol {
//    // class-only protocol definition goes here
//}
