//: Playground - noun: a place where people can play

import Cocoa
import GameplayKit

var rules = GKRuleSystem()

// You can have NSObject sub-classes in the state dictionary
class Player: NSObject
{
    dynamic var mass = 5.0
}

// The state dictionary is effectively [ Any ] and Strings are OK
rules.state.setValue("blue", forKey: "color")
rules.state.setValue(Player(), forKey: "player")

// This clears the facts so you can do another evaluate - state remains.
rules.reset()

// Make constant facts constant strings - they have to be NSString
let bigFact = "big" as NSString

// Strings make good facts, and you can set weights as long as they're Float
let factsAndWeights = [ "red": Float(0.8), bigFact: Float(0.2) ]


// You can programmatically assert facts, with starting weights
for fact in factsAndWeights {
    
    // Facts have to be coerced to NSString (NSObject subclass)
    let factName = fact.key as NSString
    rules.assertFact(factName, grade: fact.value)
}

let grossWeight = 4.0

// The $ symbol means get this key path relative to the state dictionary
// Note that if there is no 'mass' property in the player object this will
// crash when the rules system is evaluated.  Note how to compare numbers.
let pred = NSPredicate(format: "$player.mass > %f", grossWeight)

//let pred = NSPredicate(format: "$color == %@", "blue" as NSString)

// Prints "[red, big]\n"
print(rules.facts)

rules.add(GKRule(predicate: pred, assertingFact: bigFact, grade: 0.5))

// You can also write rules that address the current list of facts
let pred2 = NSPredicate(format: "ANY facts = %@", bigFact)
rules.add(GKRule(predicate: pred2, assertingFact: "bulky" as NSString, grade: 1.0))

// This is effectively an "and" of the facts - is big AND red -> swol
let pred3 = NSPredicate(format: "ALL %@ in facts", ["big", "red"])
rules.add(GKRule(predicate: pred3, assertingFact: "swol" as NSString, grade: 0.8))

// Processes the rules in order of 'salience' or failing that addition.
//    First pred is processed which tests that player mass (5) is greater than 4
//    and thus adds the fact
rules.evaluate()

// Prints "[red, really big, big, huge]\n"
print(rules.facts)

// Prints
//    red = 0.8
//    really big = 1.0
//    big = 0.2
//    huge = 1.0

for f in rules.facts
{
    let grade = rules.grade(forFact: f as! NSString)
    print(" \(f) = \(grade)")
}
