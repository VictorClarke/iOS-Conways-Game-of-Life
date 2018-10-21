//
//  GridView.swift
//  Assignment3_corrections
//
//  Created by Victor  on 7/22/17.
//  Copyright © 2017 Victor. All rights reserved.
//

import UIKit

@IBDesignable
class GridView: UIView {

    //Size of the grid square (# of rows/columns)
    @IBInspectable var rows: Int = 20 {
        didSet {
            //Resize the grid
            grid = Grid(rows,cols)
            setNeedsDisplay()
        }
    }
    
    @IBInspectable var cols: Int = 20 {
        didSet {
            //Resize the grid
            grid = Grid(rows,cols)
            setNeedsDisplay()
        }
    }
    
    //Color of living cells 
    @IBInspectable var livingColor: UIColor = UIColor.green
    //Color of just born cells
    @IBInspectable var bornColor: UIColor = UIColor.green.withAlphaComponent(0.75)
    //Color of just died cells
    @IBInspectable var diedColor: UIColor = UIColor.lightGray
    //Color of empty cells
    @IBInspectable var emptyColor: UIColor = UIColor.lightGray.withAlphaComponent(0.75)
    //Color of lines of grid
    @IBInspectable var gridColor: UIColor = UIColor.black
    
    //Width of grid
    @IBInspectable var gridWidth: CGFloat = 2
    var grid = Grid(20,20)
    
    //The size of each cell
    var cellSize: CGFloat {
        return ((frame.size.width - gridWidth) / CGFloat(cols))
    }
    
    //Far edge offset for any row/col
    func offset (_ index: Int) -> CGFloat {
        return CGFloat(index) * cellSize + cellSize
    }
    
    //Rectangle for each cell 
    func cellRect(row: Int, col: Int) -> CGRect {
        let origin = CGPoint(x: offset(col) - cellSize, y: offset(row) - cellSize)
        let size = CGSize(width: cellSize, height: cellSize)
        return CGRect(origin: origin, size: size)
    }
    
    
    override func draw(_ rect: CGRect) {
        //Drawing
        drawEdgeFrame(rect)
        drawGridLines(rect)
        
        //Draw the cells
        lazyPositions(grid.size).forEach
        { position in
            let cellState = grid[position.row, position.col]
            let cellColor: UIColor
            
            //fundemental rules of Conway's Game of Life
            switch cellState{
            case .born: cellColor = bornColor
            case .alive: cellColor = livingColor
            case .died: cellColor = diedColor
            case .empty: cellColor = emptyColor
            }
            
            drawCircle(row: position.row, col: position.col, color: cellColor)
        }
    }
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let touchesLocation = touches.first?.location(in:self)
            else {
                return
        }
        
        let cell = cellFromPoint(touch: touchesLocation)
        let cellState = grid[cell.row, cell.col]
        
        grid[cell.row, cell.col] = cellState.toggle(value: cellState)
        
        self.setNeedsDisplay()
    }
    
    
    //Helper methods for drawing
    func drawEdgeFrame(_ rect: CGRect) {
        //Define the path around the edges
        let edgePath = UIBezierPath()
        //Define how the edges will be drawn
        edgePath.lineWidth = gridWidth
        //Draw the lines for the outline/edges
        edgePath.lineWidth = gridWidth
        //Draw the lines for the outline/edges
        edgePath.move(to: rect.origin)
        edgePath.addLine(to: CGPoint(x: rect.origin.x, y: rect.size.height))
        edgePath.addLine(to: CGPoint(x: rect.size.width, y: rect.height))
        edgePath.addLine(to: CGPoint(x: rect.width, y: rect.origin.y))
        edgePath.addLine(to: CGPoint(x: rect.origin.x, y: rect.origin.y))
        
        //Define the grid color
        gridColor.setStroke()
        //Draw them 
        edgePath.stroke()
    }
    
    
    func drawGridLines(_ rect: CGRect) {
        //Helper method to draw the grid lines 
        func drawGridLine(from: CGPoint, to: CGPoint) {
            let gridLinePath = UIBezierPath()
            gridLinePath.lineWidth = gridWidth
            
            gridLinePath.move(to: from)
            gridLinePath.addLine(to: to)
            
            gridColor.setStroke()
            gridLinePath.stroke()
        }
        
        //Draw the gridlines between the edges
        for cellline in 0..<rows {
            let offset = self.offset(cellline)
            
            //Helper method to calculate the horizontal points for the cells 
            func horizontalEndPoints() -> (begin: CGPoint, end: CGPoint)
                {
                return (CGPoint(x: offset, y: rect.origin.y),CGPoint(x:offset, y: rect.size.width))
            }
            
            //Helper method to calculate the vertical points for these cells
            func verticalEndPoints() -> (begin: CGPoint, end: CGPoint)
                {
                return (CGPoint(x: rect.origin.x, y: offset), CGPoint(x: rect.size.height, y: offset))
            }
            
            //Draw the horizontal line
            drawGridLine(from: horizontalEndPoints().begin, to: horizontalEndPoints().end)
            //Draw the vertical line
            drawGridLine(from: verticalEndPoints().begin, to: verticalEndPoints().end)
        }
    }
    
    func drawCircle(row: Int, col: Int, color: UIColor) {
        let cellRect = self.cellRect(row: row, col: col)
        let midPoint = CGPoint(x: cellRect.midX, y: cellRect.midY)
        let radius = cellRect.width/2 - gridWidth
        
    
        //Define our circular path for a quarter of the screen 
        //Define the parts of the circle that we're drawing 
        let circlePath = UIBezierPath(arcCenter: midPoint, radius: radius, startAngle: CGFloat(0), endAngle: CGFloat(Double.pi * 2), clockwise: true)
        
        //Defn=ine the line color 
        color.setStroke()
        circlePath.stroke()
        //Define the fill color
        color.setFill()
        circlePath.fill()
    }
    
    //Helper methods for touches
    func cellFromPoint(touch: CGPoint) -> (row:Int, col: Int) {
        let row = Int(touch.y / cellSize)
        let col = Int(touch.x / cellSize)
        return (row: row, col: col)
    }
}



