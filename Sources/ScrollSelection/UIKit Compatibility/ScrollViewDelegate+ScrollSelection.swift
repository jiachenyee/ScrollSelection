//
//  UIScrollViewDelegate+ScrollSelection.swift
//  Scroll Selection Demo
//
//  Created by JiaChen(: on 28/9/20.
//

import Foundation
import UIKit

// MARK: - ScrollView Delegate
public extension ScrollSelection {
    /// Update ScrollSelection when the scrollview scrolls
    ///
    /// Updates scroll selection by highlighting or removing highlights
    /// on corresponding buttons
    ///
    /// # Usage
    /// To be called in `scrollViewDidScroll` function that is part of `UIScrollViewDelegate`
    ///
    /// ```swift
    /// extension ViewController: UIScrollViewDelegate {
    ///     func scrollViewDidScroll(_ scrollView: UIScrollView) {
    ///         scrollSelection.didScroll()
    ///     }
    /// }
    /// ```
    func didScroll() {
        
        // If scroll selection is inactive, don't scroll select
        if !isActive { return }
        
        if let offset = scrollView?.contentOffset.y {
            
            if let section = getCurrentSection(offset) {
                
                // Get current and previous buttons
                let buttons = getSelectedViews(atSection: section)

                if let button = buttons.current {
                    let shapeLayer: CAShapeLayer = {
                        if let layer = button.layer.sublayers?.first as? CAShapeLayer {
                            return layer
                        }
                        
                        var layerView = button
                        
                        if let searchBar = button as? UISearchBar {
                            layerView = searchBar.searchTextField.superview!
                            
                            if let layer = layerView.layer.sublayers?.first as? CAShapeLayer {
                                return layer
                            }
                        }
                        
                        let layer: CAShapeLayer = .init()
                        
                        layer.path = .zero

                        layerView.layer.insertSublayer(layer, at: 0)
                        
                        return layer
                    }()
                    
                    var multiplier = (offset / -offsetMultiplier) - CGFloat(section + 1)
                    
                    if multiplier > 1 {
                        multiplier = 1
                    }
                    
                    // Getting the highlight style
                    let highlightStyle = style.filter { $0.rawValue == 1 }.first
                    
                    // Getting the circular highlight style
                    let circularHighlightStyle = style.filter { $0.rawValue == 2 }.first
                    
                    // Adding highlight style
                    if let style = highlightStyle {
                        let color = style.color ?? tintColor.withAlphaComponent(0.7)
                        
                        button.tintColor = color
                    }
                    
                    // Adding circular highlight style
                    if let style = circularHighlightStyle {
                        
                        let color = style.color ?? UIColor.red
                        let expands = style.expands ?? true
                        let fades = style.fades ?? true
                        
                        if fades {
                            shapeLayer.fillColor = color.withAlphaComponent(multiplier).cgColor
                        } else {
                            shapeLayer.fillColor = color.cgColor
                        }
                        
                        if expands {
                            shapeLayer.path = getExpandingCirclePath(with: multiplier, button: button)
                        } else {
                            shapeLayer.path = getStaticCirclePath(button: button)
                        }
                    }
                }
                
                playHaptics(withSection: section)

                deselectAll(views: buttons.previous)

            } else {
                currentSection = -1
                
                if let lastButton = getViews().first {
                    deselectView(lastButton)
                }
            }
        } else {
            print("⚠️ ScrollSelection Warning ⚠️\nNo Scroll View found.\nEnsure that there is a Scroll View in the View Controller\nUse `scrollSelection.scrollView = ...` to set your scrollView manually.")
        }
    }
    
    /// Update ScrollSelection when user stops dragging scrollView
    ///
    /// Called when scrollView is released (ends dragging) and thus, scroll selection will
    /// select the corresponding bar button
    ///
    /// # Usage
    /// To be called in `scrollViewDidEndDragging` function that is part of `UIScrollViewDelegate`
    ///
    /// ```swift
    /// extension ViewController: UIScrollViewDelegate {
    ///     func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    ///         scrollSelection.didEndDragging()
    ///     }
    /// }
    /// ```
    func didEndDragging() {
        
        // Don't launch buttons if it is inactive
        if !isActive { return }
        
        let views = getViews()
        
        if let offset = scrollView?.contentOffset.y {
            
            if let section = getCurrentSection(offset) {
                
                let view = views[section]
                
                if let button = view as? UIButton {
                    if let actions = button.actions(forTarget: parent,
                                                   forControlEvent: .touchUpInside) {
                        actions.forEach {
                            parent.performSelector(onMainThread: Selector($0),
                                                   with: nil,
                                                   waitUntilDone: true)
                        }
                    }
                } else if let searchBar = view as? UISearchBar {
                    searchBar.becomeFirstResponder()
                }
                
                deselectAll(views: views)
            }
        }
    }
    
    /// Update ScrollSelection once the scrollView stops decelerating
    ///
    /// Called when scrollView is ends deceerating and thus, scroll selection will
    /// reset to original state
    ///
    /// # Usage
    /// To be called in `scrollViewDidEndDecelerating` function that is part of `UIScrollViewDelegate`
    ///
    /// ```swift
    /// extension ViewController: UIScrollViewDelegate {
    ///     func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    ///         scrollSelection.didEndDecelerating()
    ///     }
    /// }
    /// ```
    func didEndDecelerating() {
        
        // Don't reset to default if scrollSelection is inactive
        if !isActive { return }
        
        let views = getViews()
        
        deselectAll(views: views)
    }
}

