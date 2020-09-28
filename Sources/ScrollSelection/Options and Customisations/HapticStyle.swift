//
//  HapticStyle.swift
//  Scroll Selection Demo
//
//  Created by JiaChen(: on 28/9/20.
//

import Foundation

public extension ScrollSelection {
    /// The styles to play the haptic feedback which is used to alert the user of a new selection
    enum HapticsStyle {
        
        /// Normal Haptic Style
        case normal
        
        /// No haptics
        case disabled
        
        /// Default style, Haptic feedback becomes more pronounced as user scrolls up
        ///
        /// ```
        /// First Button -> Last Button
        /// Weak         -> Strong
        /// ```
        case variableIncreasing
        
        /// Haptic feedback becomes less pronounced as user scrolls up
        ///
        /// ```
        /// First Button -> Last Button
        /// Strong       -> Weak
        /// ```
        case variableDecreasing
    }
}
