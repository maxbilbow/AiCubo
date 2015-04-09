// Playground - noun: a place where people can play

import Cocoa
import GLKit

func number(first: Int) -> (Int ->Int) {
    return { second in return first * second }
}

number(2)(number(2)(2))
