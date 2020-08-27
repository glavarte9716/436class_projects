//
//  model.swift
//  assign1
//
//  Created by Gabe Lavarte on 2/18/20.
//  Copyright © 2020 Gabe Lavarte. All rights reserved.
//

import Foundation

let emptyBoard: [[Int]] = [[0,0,0,0],[0,0,0,0],[0,0,0,0],[0,0,0,0]]

enum Direction {
    case up
    case down
    case left
    case right
}

class Triples {
    
    public var board: [[Int]]
    public var score: Int

    init() {
        board = emptyBoard
        score = 0;
    }
    
    // re-inits 'board', and any other state you define
    func newgame() {
        for i in 0...3 {
            for j in 0...3 {
                let random_int = Int.random(in: 0...2)
                board[i][j] = random_int
            }
        }
    }
    
    func rotate() {
        board = rotate2D(input: board)
    }
    
    //collapse to the left.
    func shift() {
        for (index, _) in board.enumerated() {
            shiftRow(input: &board[index]);
        }
    }
    
    func collapse(dir: Direction) {
        //if swipping right, rotate twice and shift.
        if dir == .right {
            rotate()
            rotate()
            shift()
            rotate()
            rotate()
        }
            //rotate 3 times, shift and rotate once.
        else if dir == .up {
            rotate()
            rotate()
            rotate()
            shift()
            rotate()
        }
            //rotate once then shift and rotate 3 more times.
        else if dir == .down {
            rotate()
            shift()
            rotate()
            rotate()
            rotate()
        }
            //just shift for a left collapse
        else {
            shift()
        }
        
    }        // collapse in specified direction using shift() and rotate()
    
    //This will shift a single array from index 3 to index 0.
    func shiftRow(input: inout [Int]) {
        for (index, _) in input.enumerated() {
            //if this index is an empty spot and is not the last cell, shift vals.
            if  index < 3 && input[index] == 0{
                    input[index] = input[index+1]
                    input[index+1] = 0;
            }
            //else index is not empty and needs to be added with the val next to it if
                // the value is divisible by 3.
            else {
                //index must be less than 3.
                if  index < 3 &&
                    //either the indices sum to 3 without either one being 0, or
                    (((input[index] + input[index+1]) == 3 && input[index+1] != 0) ||
                        //they equal eachother and are divisible by 3 when added.
                        (input[index] == input[index+1] && (input[index] + input[index+1]) % 3 == 0)) {
                    
                        input[index] = input[index]+input[index+1]
                        input[index+1] = 0
                }
            }
        }
    }
}


// rotate a square 2D Int array clockwise
public func rotate2DInts(input: [[Int]]) -> [[Int]] {
    var newBoard: [[Int]] = emptyBoard
    var destI = 0
    var destJ = 3
    for i in 0...3 {
        for j in 0...3 {
            newBoard[destI][destJ] = input[i][j]
            destI+=1
        }
        destJ-=1
        destI = 0
    }
    return newBoard
}

// rotate a square generic 2D array clockwise
public func rotate2D<T>(input: [[T]]) -> [[T]] {
    var newBoard: [[T]] = input
    var destI = 0
    var destJ = 3
    for i in 0...3 {
        for j in 0...3 {
            newBoard[destI][destJ] = input[i][j]
            destI+=1
        }
        destJ-=1
        destI = 0
    }
    return newBoard

}
