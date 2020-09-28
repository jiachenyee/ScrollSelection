//
//  Style.swift
//  Scroll Selection Demo
//
//  Created by JiaChen(: on 28/9/20.
//

import Foundation
import UIKit

public extension ScrollSelection {
    
    /// Customise Scroll Selection using `Style` to change colors, animations and more.
    struct Style {
        
        public var rawValue: Int
        
        /// Storing color value as parameter
        var color: UIColor?
        
        /// Storing expanding style as parameter
        var expands: Bool?
        
        /// Storing fade style as parameter
        var fades: Bool?
        
        /// Get `Style` using raw value
        /// - Parameter rawValue: Raw value for style
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
        
        /// Changes the Button color during Scroll Selection
        /// - Parameter color: Color to change to. Default is `.systemBlue` with alpha of 0.7
        /// - Returns: A scroll selection style
        public static func highlight(using color: UIColor = UIColor.systemBlue.withAlphaComponent(0.7)) -> Style {
            var style = Style(rawValue: 1 << 0)
            style.color = color
            
            return style
        }
        
        /// Adds a circular highlight to the button that is being selected
        /// - Parameters:
        ///   - color: Color of the highlight
        ///   - expands: If true, circular highlights will expand radially to show emphasis on the button as
        ///    the user scrolls up. Otherwise, it will stay static and the highlight will not expand.
        ///   - fades: If true, circular highlight background will fade as the user scrolls up.
        ///    Otherwise, it will jump from one to another, without fading.
        /// - Returns: A scroll selection style
        public static func circularHighlight(using color: UIColor = .systemGray5,
                                             expands: Bool = true,
                                             fades: Bool = true) -> Style {
            
            var style = Style(rawValue: 1 << 1)
            
            style.color = color
            style.expands = expands
            style.fades = fades
            
            return style
        }
        
        /// Default scroll selection style
        public static let defaultStyle: [Style] = [highlight(),
                                                   circularHighlight()]
    }
}
