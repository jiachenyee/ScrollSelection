//
//  Direction.swift
//  Scroll Selection Demo
//
//  Created by JiaChen(: on 28/9/20.
//

import Foundation

public extension ScrollSelection {
    
    /// Indicate the side(s) to update UIBarButtonItems using directions
    struct Direction: OptionSet {
        
        public var rawValue: Int
        
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
        
        /// Update Left Bar Buttons
        public static let left: Direction  = Direction(rawValue: 1 << 0)
        
        /// Update Right Bar Buttons
        public static let right: Direction = Direction(rawValue: 1 << 1)
        
        /// Update Both Right and Left Bar Buttons
        public static let all: Direction   = [.left, .right]
    }
}
