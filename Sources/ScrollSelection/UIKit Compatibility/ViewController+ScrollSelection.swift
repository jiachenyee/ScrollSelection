//
//  UIViewController+ScrollSelection.swift
//  Scroll Selection Demo
//
//  Created by JiaChen(: on 28/9/20.
//

import Foundation
import UIKit

// MARK: UIViewController Implementation
@available(iOS 13.0, *)
public extension UIViewController {
    
    /// Set-Up Scroll Selection on this View Controller
    ///
    /// - Parameters:
    ///   - offsetMultiplier: Distance between each button selection
    ///   - style: Scroll Selection Style.
    ///   Use `ScrollSelection.Style.defaultStyle` for default implementation
    ///   or remove this parameter
    ///
    /// - Returns: An instance of Scroll Selection that is already set up
    func createScrollSelection(withOffset offsetMultiplier: CGFloat = 50,
                               usingStyle style: [ScrollSelection.Style] = ScrollSelection.Style.defaultStyle) -> ScrollSelection {
        
        updateBarButtons()
        
        let scrollView = self.view.subviews.filter {
            $0.isMember(of: UIScrollView.self) || $0 is UIScrollView
        }.first as? UIScrollView
        
        return ScrollSelection(vc: self,
                               selectedStyle: style,
                               offsetMultiplier: offsetMultiplier,
                               scrollView: scrollView)
    }
    
    /// Update bar buttons with Scroll Selection
    ///
    /// Call this function whenever a change is made to the navigation bar buttons
    ///
    /// - Parameter direction: `.left` corresponds to the left bar buttons,
    /// `.right` corresponds to the right bar buttons,
    /// `.all` updates all buttons.
    func updateBarButtons(barButtonSide direction: ScrollSelection.Direction = .all) {
        if navigationController != nil {
            
            // Updating left bar buttons
            if direction.contains(.left) {
                let leftBarButtonItems = navigationItem.leftBarButtonItems ?? []
                
                navigationItem.setLeftBarButtonItems(ScrollSelection.convertBarButtons(using: leftBarButtonItems), animated: false)
            }
            
            // Updating right bar buttons
            if direction.contains(.right) {
                let rightBarButtonItems = navigationItem.rightBarButtonItems ?? []
                
                let convertedButtons = ScrollSelection.convertBarButtons(using: rightBarButtonItems)
                
                navigationItem.setRightBarButtonItems(convertedButtons, animated: false)
                
            }
        } else {
            print("⚠️ ScrollSelection Warning ⚠️\nView Controller not in a Navigation Controller.\nEnsure that \(description) is embeded in a Navigation Controller")
        }
    }
}
