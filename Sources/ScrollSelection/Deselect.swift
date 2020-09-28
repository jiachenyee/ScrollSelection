//
//  Deselect+ScrollSelection.swift
//  Scroll Selection Demo
//
//  Created by JiaChen(: on 28/9/20.
//

import Foundation
import UIKit

// MARK: - Deselect
public extension ScrollSelection {
    
    /// Deselect all views
    /// - Parameter views: views to deselect
    func deselectAll(views: [UIView]) {
        
        // Loop through all views provided and deselect them
        views.forEach {
            deselectView($0)
        }
    }
    
    /// Deselect a single view
    /// - Parameter view: view to deselect
    func deselectView(_ view: UIView) {
        
        if let button = view as? UIButton {
            // If it is a button, deselect based on custom button
            deselectCustomButton(button)
            
        } else if let searchBar = view as? UISearchBar {
            
            // If it is a search bar, deselect based on search bar
            deselectSearchBar(searchBar)
            
        }
    }
    
    /// Deselect custom button, reset it to default
    /// - Parameter button: Button to be deselected
    func deselectCustomButton(_ button: UIButton) {
        if let shapeLayer = button.layer.sublayers?.first as? CAShapeLayer {
            
            button.tintColor = tintColor
            
            shapeLayer.path = .zero
        }
    }
    
    /// Deselect search bar, reset it to default
    /// - Parameter searchBar: Search bar to be deselected
    func deselectSearchBar(_ searchBar: UISearchBar) {
        
        /// Search text field from search bar
        let searchTextField = searchBar.searchTextField
        
        /// Layer of search text field's superview
        let layer = searchTextField.superview?.layer
        
        if let shapeLayer = layer?.sublayers?.first as? CAShapeLayer {
            
            // Resetting the path to zero
            shapeLayer.path = .zero
        }
    }
}
