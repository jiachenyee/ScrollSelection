//
//  Debug+ScrollSelection.swift
//  Scroll Selection Demo
//
//  Created by JiaChen(: on 28/9/20.
//

import Foundation

// MARK: - Debugging
extension ScrollSelection: CustomDebugStringConvertible, CustomStringConvertible {
    public var debugDescription: String {
        let description = "** Scroll Selection Debug **"
            + "\nParent View Controller: \(parent.debugDescription)"
            + "\nStyle: \(style.debugDescription)"
            + "\nOffset Multiplier: \(offsetMultiplier.debugDescription)"
            + "\nTarget Scroll View: \(scrollView.debugDescription)"
        
        return description
    }
    
    public var description: String {
        let description = "** Scroll Selection **"
            + "\nParent View Controller: \(parent.description)"
            + "\nStyle: \(String(describing: style))"
            + "\nOffset Multiplier: \(String(describing: offsetMultiplier))"
            + "\nTarget Scroll View: \(String(describing: scrollView))"
        
        return description
    }
}
