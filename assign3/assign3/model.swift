//
//  model.swift
//  assign3
//
//  Created by Gabe Lavarte on 3/3/20.
//  Copyright © 2020 Gabe Lavarte. All rights reserved.
//

import Foundation

let emptyBoard: [[Tile?]] = [[nil,nil,nil,nil],[nil,nil,nil,nil],[nil,nil,nil,nil],[nil,nil,nil,nil]]

enum Direction {
    case up
    case down
    case left
    case right
}

public struct Tile: Equatable {
    var val : Int
    var id : Int
    var row: Int    // recommended
    var col: Int    // recommended
    var shouldDelete: Bool
    
    public static func == (lhs: Tile, rhs: Tile) -> Bool {
        if lhs.val == rhs.val && lhs.id == rhs.id && lhs.row == rhs.row && lhs.col == rhs.col {
            return true
        }
        return false
    }
    
    mutating func setVal (valIn: Int) {
        val = valIn
    }
}

public class Triples {
    
    private var idCounter: Int
    public var board: [[Tile?]]
    public var previousTileMap: [Int:Tile]
    public var tileMap: [Int:Tile]
    public var score: Int
    
    public func getIDCount() -> Int {
        return idCounter
    }

    init() {
        board = emptyBoard
        score = 0
        idCounter = 0
        tileMap = Dictionary()
        previousTileMap = Dictionary()
    }
    
    // re-inits 'board' with an empty board
    func newgame(rand: Bool) {
        board = emptyBoard
        score = 0
        idCounter = 0
        tileMap = Dictionary()
        previousTileMap = Dictionary()
        
        if rand {
            srand48(Int.random(in:1...1000))
            
        }
        else {
            srand48(42)
        }
    }
    
    func updateTileRowCol() {
        for row in 0...3 {
            for col in 0...3 {
                if let _ = board[row][col] {
                    var updated = board[row][col]!
                    updated.row = row
                    updated.col = col
                    tileMap[updated.id] = updated
                }
            }
        }
    }
    
    //add isDone() function by checking all possible collapses and checking for empty
    //spaces.
    func isDone() -> Bool {
        var emptyCount = 0;
        //checking for number of empty spots in the board.
        for x in 0...3 {
            for y in 0...3 {
                if board[x][y] == nil {
                    emptyCount += 1
                }
            }
        }
        
        //Are there moves capable of being made on the board
        let isBoardShiftable = shiftable(testedBoard: board)
        
        if emptyCount == 0 && !isBoardShiftable {
            return true
        }
        return false
    }
    
    //spawn a new tile and put it in the board.
    func spawn() {
        //starting at position 0, we add the index of each tile as the value to the position key.
        var availableSpotsMap : [Int:ViewController.Index] = [:]
        var position = 0
        for x in 0...3 {
            for y in 0...3 {
                if board[x][y] == nil {
                    availableSpotsMap[position] = ViewController.Index(x,y)
                    position += 1
                }
            }
        }
        
        //only if the available spots is not empty, we get the random position using
        //the position max.
        if !availableSpotsMap.isEmpty {
            //new tile will either be 2 or 1
            let newTileVal = prng(max: 2) + 1
            score += newTileVal
            let newTilePosition = prng(max: position) 
            let newTileIndex = availableSpotsMap[newTilePosition]
            if let row = newTileIndex?.x , let col = newTileIndex?.y {
                let newTile = Tile(val: newTileVal, id: idCounter, row: row, col: col, shouldDelete: false)
                board[row][col] = newTile
                tileMap[idCounter] = newTile
                idCounter+=1
            }
        }
        else {
            print("We have no new available spaces.")
        }
        updateTileRowCol()
        
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
    
    func collapse(dir: Direction) -> Bool{
        //if swipping right, rotate twice and shift.
        let previousBoard = board
        previousTileMap = tileMap
        switch dir {
        case .right:
            rotate()
            rotate()
            shift()
            rotate()
            rotate()
        case .up:
            rotate()
            rotate()
            rotate()
            shift()
            rotate()
        case .down:
            rotate()
            shift()
            rotate()
            rotate()
            rotate()
        case .left:
            shift()
        }
        updateTileRowCol()
        if previousBoard == board { return false }
        else { return true }
    }
    // collapse in specified direction using shift() and rotate()
    
    //This will shift a single array from index 3 to index 0.
    func shiftRow(input: inout [Tile?]) {
        for (index, _) in input.enumerated() {
            //if this index is an empty spot and is not the last cell, shift vals.
            if  index < 3 && input[index] == nil {
                input[index] = input[index+1]
                input[index+1] = nil;
            }
                //else index is not empty and needs to be added with the val next to it if
                //it is shiftable
            else {
                //index must be less than 3.
                if index < 3 {
                    //two tiles must not be empty for there to be a collapse.
                    if let tile1 = input[index], let tile2 = input[index+1] {
                        
                        //either the indices sum to 3 without either one being 0, or
                        if  (tile1.val + tile2.val == 3  ||
                            //they equal eachother and are divisible by 3 when added.
                            (tile1.val == tile2.val && ((tile1.val + tile2.val) % 3 == 0))) {
                            
                            //then collapse by making the shifted tile the correct value of tile
                            //then make sure to remove the other tile from the tilemap.
                            var updatedTile = input[index+1]!
                            updatedTile.val = tile1.val + tile2.val
                            score += updatedTile.val
                            input[index] = updatedTile
                            input[index+1] = nil
                            tileMap[tile1.id] = nil
                            tileMap[tile2.id] = updatedTile
                        }
                    }
                }
            }
        }
    }
    
    //use rotate2DInts and this helper function to check shiftability.
    func shiftableRow(input: [Tile?]) -> Bool {
        for (index, _) in input.enumerated() {
            //if this index is an empty spot and is not the last cell, shift vals.
            if  index < 3 && input[index] == nil {
                    return true
            }
            //second shiftable scenario.
            else {
                //index must be less than 3.
                if index < 3 {
                    if let tile1 = input[index] , let tile2 = input[index+1] {
                        //either the indices sum to 3 without either one being 0, or
                        if   ((tile1.val + tile2.val == 3) ||
                            //they equal eachother and are divisible by 3 when added.
                            (tile1.val == tile2.val && (tile1.val + tile2.val) % 3 == 0)) {
                            return true
                        }
                    }
                }
            }
        }
        
        return false
    }
    
    
    //STUCK CHECKING SHIFTABILITY
    func shiftable(testedBoard: [[Tile?]]) -> Bool {
        //call shiftableRow on every row, in every orientation of the board.
        
        //first call shiftableRow on a left collapse.
        for (index, _) in testedBoard.enumerated() {
            let shiftedBool = shiftableRow(input: testedBoard[index])
            if shiftedBool {
                return true
            }
        }
        //rotate once, then check shiftability.
        var shiftedBoard = rotate2D(input: testedBoard)
        for (index, _) in shiftedBoard.enumerated() {
            let shiftedBool = shiftableRow(input: shiftedBoard[index])
            if shiftedBool {
                return true
            }
        }
        
        //rotate twice, then check shiftability.
        shiftedBoard = rotate2D(input: testedBoard)
        shiftedBoard = rotate2D(input: shiftedBoard)
        for (index, _) in shiftedBoard.enumerated() {
            let shiftedBool = shiftableRow(input: shiftedBoard[index])
            if shiftedBool {
                return true
            }
        }
        
        //rotate 3 times, then check shiftability
        shiftedBoard = rotate2D(input: testedBoard)
        shiftedBoard = rotate2D(input: shiftedBoard)
        shiftedBoard = rotate2D(input: shiftedBoard)
        for (index, _) in shiftedBoard.enumerated() {
            let shiftedBool = shiftableRow(input: shiftedBoard[index])
            if shiftedBool {
                return true
            }
        }
        
        //if not shiftable in any of the 4 directions return false.
        
        return false
    }
    
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

public func prng(max: Int) -> Int {
    let ret = Int(floor(drand48() * (Double(max))))
    return (ret < max) ? ret : (ret-1)
}


