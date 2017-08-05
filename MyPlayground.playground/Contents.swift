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
rules.state.setValue(5.0, forKey: "height")

// Make constant facts constant strings - they have to be NSString 
// to use in a GKRule since they are NSObjectProtocol objects
let bigFact = "big" as NSString
let checkJacketFact = "chequered" as NSString
let badTaste = "bad taste" as NSString
let redFact = "red" as NSString
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

// People over 3ft high are "tall" - add 0.4 to the grade of the tall fact
let pred4 = NSPredicate(format: "$height > %f", 3.0)
let heightRule = GKRule(predicate: pred4, assertingFact: "tall" as NSString, grade: 0.4)
rules.add(heightRule)

// People over 4ft high are even more "tall" - add another 0.4 to the grade of tall
let pred5 = NSPredicate(format: "$height > %f", 4.0)
let ballerRule = GKRule(predicate: pred4, assertingFact: "tall" as NSString, grade: 0.4)
rules.add(ballerRule)

let pred6 = NSPredicate(format: "%@ IN facts", checkJacketFact)
let takeOffChequeredJacket = GKRule(predicate: pred6, retractingFact: checkJacketFact, grade: 1.1)
takeOffChequeredJacket.salience = 10000
// Execute taking off the jacket right at the beginning to avoid dontLikeChecks
// judgements from our style police rules engine!
// NOTE - have to set the salience BEFORE adding the rule to the system
rules.add(takeOffChequeredJacket)

let predNext = NSPredicate(format: "%@ IN facts", checkJacketFact)
let dontLikeChecks = GKRule(predicate: predNext, assertingFact:badTaste, grade: 0.8)
rules.add(dontLikeChecks)

rules.reset()

// Strings make good facts, and you can set weights as long as they're Float
let factsAndWeights = [ redFact: Float(0.5),
                        bigFact: Float(0.2),
                        checkJacketFact: Float(1.0) ]


// You can programmatically assert facts, with starting weights
for fact in factsAndWeights {
    
    // Facts have to be coerced to NSString (NSObject subclass)
    let factName = fact.key as NSString
    rules.assertFact(factName, grade: fact.value)
}


// Processes the rules in order of 'salience' or failing that addition.
//    First pred is processed which tests that player mass (5) is greater than 4
//    and thus adds the fact
rules.evaluate()


// Prints "[red, tall, bulky, swol, bad taste, big]"
print(rules.facts)

for f in rules.facts
{
    let grade = rules.grade(forFact: f as! NSString)
    print(" \(f) = \(grade)")
}
