//: Playground - noun: a place where people can play

import Cocoa
import GameplayKit

var str = "Hello, playground"

print(str)

class Player: NSObject
{
    dynamic var weight = 5.0
}

let factsAndWeights = [ "red": Float(0.8), "big": Float(0.2) ]

let bigFact = "huge" as NSString

var rules = GKRuleSystem()

rules.state.setValue("blue", forKey: "color")
rules.state.setValue(Player(), forKey: "player")

rules.reset()

for fact in factsAndWeights {
    
    // Facts have to be coerced to NSString (NSObject subclass)
    let factName = fact.key as NSString
    rules.assertFact(factName, grade: fact.value)
}

let grossWeight = 4.0

let pred = NSPredicate(format: "$player.weight > %f", grossWeight)

//let pred = NSPredicate(format: "$color == %@", "blue" as NSString)

print(rules.facts)

rules.add(GKRule(predicate: pred, assertingFact: bigFact, grade: 1.0))


let pred2 = NSPredicate(format: "ANY facts LIKE %@", "red" as NSString)
rules.add(GKRule(predicate: pred2, assertingFact: "really big" as NSString, grade: 1.0))

rules.evaluate()
print(rules.facts)

rules.assertFact(str as NSString, grade: 1.0)

rules.facts

print(rules.state)
