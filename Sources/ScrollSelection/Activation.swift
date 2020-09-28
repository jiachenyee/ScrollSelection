//
//  Activation.swift
//  Scroll Selection Demo
//
//  Created by JiaChen(: on 28/9/20.
//

import Foundation

// MARK: - Activating/Deactivating
public extension ScrollSelection {
    /// Deactivate Scroll Selection
    func deactivate() {
        isActive = false
    }
    
    /// Activate Scroll Selection
    func activate() {
        isActive = true
    }
}
