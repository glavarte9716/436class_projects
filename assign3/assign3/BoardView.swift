//
//  BoardView.swift
//  assign3
//
//  Created by Gabe Lavarte on 4/5/20.
//  Copyright © 2020 Gabe Lavarte. All rights reserved.
//

import UIKit

class BoardView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    
    //Drawing of the grid lines.
    var path = UIBezierPath()
    
    func buttonFrame(row: Int, col: Int, view: UIView) -> CGRect {
           let boardFrame:CGRect = view.bounds
           let tileLength = boardFrame.width / 4
           let x = CGFloat(col) * tileLength
           let y = CGFloat(row) * tileLength
           return CGRect(x: x, y: y, width: tileLength, height: tileLength)
    }
    
    override func draw(_ rect: CGRect) {
        let tileLength = CGFloat(bounds.width/4)
        path = UIBezierPath()
        path.lineWidth = 3.0
        
        //first draw the Vertical lines from left to right
        for index in 0...3 {
            let start = CGPoint(x: CGFloat(index) * tileLength, y: 0)
            let end = CGPoint(x: CGFloat(index) * tileLength, y: bounds.height)
            path.move(to: start)
            path.addLine(to: end)
        }
        
        // draw the horizontal lines of the gird
        for index in 0...3 {
            let start = CGPoint(x: 0, y: CGFloat(index)*tileLength)
            let end = CGPoint(x:bounds.width, y: CGFloat(index)*tileLength)
            path.move(to: start)
            path.addLine(to: end)
        }
        path.stroke()
    }
    
    override func layoutSubviews() {
        var newTilesToFade = [ButtonTile]()
        for view in subviews {
            //Ensures safe casting to button tile to manipulate the button's properties.
            if view is ButtonTile {
                let buttonTile = view as! ButtonTile
                let tile = buttonTile.getTile()
                
                //Immediately animate deletion of this tile if it is marked for it.
                           
                if tile.shouldDelete {
                    buttonTile.isHidden = false
                    buttonTile.layer.opacity = 1
                    UIView.animate(withDuration: 0.3, animations: {
                        buttonTile.layer.opacity = 0
                    })
                    
                    //after animating the disappearance, remove from the superview.
                    buttonTile.removeFromSuperview()
                }
                
                //Set the frame of where the button should currently be.
                let frame = buttonFrame(row: tile.row, col: tile.col, view: self)
                buttonTile.frame = frame
                //Change the title to its number value and the colors corresponding to it.
                buttonTile.setTitle(String(tile.val), for: UIControl.State.normal)
                if tile.val == 2 {
                    buttonTile.backgroundColor = #colorLiteral(red: 0.8549019694, green: 0.250980407, blue: 0.4784313738, alpha: 1)
                    buttonTile.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), for: UIControl.State.normal)
                }
                else if tile.val == 1 {
                    buttonTile.backgroundColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
                    buttonTile.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), for: UIControl.State.normal)
                }
                else {
                    buttonTile.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
                    buttonTile.setTitleColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), for: UIControl.State.normal)
                }
                
                //adds the invisible new buttons to a list of tiles that will spawn.
                if buttonTile.isHidden {
                    newTilesToFade.append(buttonTile)
                }
                
                //if there is any change in this tile's position, animate it.
                if let previousCol = buttonTile.previousCol, let previousRow = buttonTile.previousRow {
                    if previousCol != buttonTile.tile.col || previousRow != buttonTile.tile.row {
                        let previousFrame = buttonFrame(row: previousRow, col: previousCol, view: self)
                        buttonTile.frame = previousFrame
                        UIView.animate(withDuration: 0.25, animations: {
                            buttonTile.frame = frame
                        })
                    }
                }
            }
            
            
        }
        //animate all of the tiles to appear.
        for newButton in newTilesToFade {
            newButton.isHidden = false
            UIView.animate(withDuration: 0.30 , animations: {
                newButton.layer.opacity = 1
            })
        }
        
        
    }
}
