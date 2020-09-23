import UIKit
import Foundation

@available(iOS 13.0, *)
public class ScrollSelection {
    
    static let edgeOffset: CGFloat = 8
    
    var parent: UIViewController!
    var style: [Style]!
    var offsetMultiplier: CGFloat!
    var scrollView: UIScrollView?
    
    /// Haptic feedback styles
    var hapticStyle: HapticsStyle = HapticsStyle.normal(style: .medium)
    
    /// Activate or deactivate scroll selection
    var isActive = true
    
    /// To support Haptic Feedback, ensuring that users
    /// do not get spammed with random vibrations
    var currentSection: Int = -1
    
    /// Set up scroll selection
    /// - Parameters:
    ///   - vc: Parent View Controller
    ///   - selectedStyle: Intended scroll selection styles
    ///   - offsetMultiplier: Y-axis offset before when selecting buttons
    ///   - scrollView: ScrollView to target
    public init(vc: UIViewController,
                selectedStyle: [Style],
                offsetMultiplier: CGFloat,
                scrollView: UIScrollView?) {
        
        self.parent = vc
        self.style = selectedStyle
        self.offsetMultiplier = offsetMultiplier
        self.scrollView = scrollView
    }
    
    /// Get current section using the scrollView's y offset
    /// - Parameter offset: Y-axis of the scrollView's content offset
    /// - Returns: Current section or `nil` if nothing is selected
    func getCurrentSection(_ offset: CGFloat) -> Int? {
        let buttons = (parent.navigationItem.leftBarButtonItems ?? []) + (parent.navigationItem.rightBarButtonItems ?? [])
        
        var currentSection = Int(floor(offset / -offsetMultiplier))
        
        let max = buttons.count
        
        if currentSection > max {
            currentSection = max
        } else if currentSection <= 0 {
            return nil
        }
        
        currentSection -= 1
        
        return currentSection
    }
    
    /// Getting the selected button based on the current section
    /// - Parameter section: Current selected section
    /// - Returns: The previous and currently selected bar buttons
    func getSelectedButtons(atSection section: Int) -> (previous: UIBarButtonItem?, current: UIBarButtonItem?){
        let leftBarButtons = parent.navigationItem.leftBarButtonItems ?? []
        let rightBarButtons = parent.navigationItem.rightBarButtonItems ?? []
        
        var selectedBarButton: UIBarButtonItem?
        var previousBarButton: UIBarButtonItem?
        
        if rightBarButtons.count - 1 >= section {
            
            selectedBarButton = rightBarButtons[section]
            
            if section > 0 {
                previousBarButton = rightBarButtons[section - 1]
            }
            
        } else {
            
            selectedBarButton = leftBarButtons[section - rightBarButtons.count]
            
            if section > 0 {
                previousBarButton = leftBarButtons[section - 1 - rightBarButtons.count]
            }
        }
        
        return (previous: previousBarButton, current: selectedBarButton)
    }
    
    /// Get CGPath for static circles (circles that do not expand)
    /// - Parameter button: Button to inherit path
    /// - Returns: CGPath that can be added into the layer
    func getStaticCirclePath(button: UIButton) -> CGPath {
        
        let maxWidth = button.frame.width + ScrollSelection.edgeOffset * 2
        let maxHeight = button.frame.height + ScrollSelection.edgeOffset * 2
        
        return CGPath(roundedRect: .init(x: -ScrollSelection.edgeOffset,
                                         y: -ScrollSelection.edgeOffset,
                                         width: maxWidth,
                                         height: maxHeight),
                      cornerWidth: maxHeight / 2,
                      cornerHeight: maxHeight / 2,
                      transform: nil)
    }
    
    /// Get CGPath for expanding circle paths
    /// - Parameters:
    ///   - multiplier: A value, from 0.0 to 1.0 to show how much to expand/shrink path
    ///   - button: Button to inherit the path
    /// - Returns: CGPath that can be added into the layer
    func getExpandingCirclePath(with multiplier: CGFloat, button: UIButton) -> CGPath {
        
        let maxWidth = button.frame.width + ScrollSelection.edgeOffset * 2
        let maxHeight = button.frame.height + ScrollSelection.edgeOffset * 2
        
        let width = maxWidth * multiplier
        let height = maxHeight * multiplier
        
        let xEdgeOffset: CGFloat = -ScrollSelection.edgeOffset + (maxWidth - width) / 2
        let yEdgeOffset: CGFloat = -ScrollSelection.edgeOffset + (maxHeight - height) / 2
        
        return CGPath(roundedRect: .init(x: xEdgeOffset,
                                         y: yEdgeOffset,
                                         width: width,
                                         height: height),
                      cornerWidth: height / 2,
                      cornerHeight: height / 2,
                      transform: nil)
    }
    
    /// Deselect custom button, reset it to default
    /// - Parameter button: Button to be deselected
    func deselectCustomButton(_ button: UIButton) {
        if let shapeLayer = button.layer.sublayers?.first as? CAShapeLayer {
            
            button.tintColor = .systemBlue
            
            shapeLayer.path = CGPath(roundedRect: .zero,
                                     cornerWidth: .zero,
                                     cornerHeight: .zero,
                                     transform: nil)
        }
    }
    
    /// Play haptic feedback based on current section
    ///
    /// This function also ensures that haptic feedback is not played multiple times in the same section
    ///
    /// - Parameter section: Current section user is on
    func playHaptics(withSection section: Int) {
        let styles: [UIImpactFeedbackGenerator.FeedbackStyle] = [.soft, .rigid, .medium, .light, .heavy]
        
        let index = section % styles.count
        
        if currentSection == section { return }
        
        currentSection = section
        
        switch hapticStyle {
        case HapticsStyle.normal(let feedback):
            UIImpactFeedbackGenerator(style: feedback).impactOccurred()
            
        case .variableDecreasing:
            
            UIImpactFeedbackGenerator(style: styles.reversed()[index]).impactOccurred()
            
        case .variableIncreasing:
            
            UIImpactFeedbackGenerator(style: styles[index]).impactOccurred()
            
        default:
            break
        }
    }
    
    /// Deactivate Scroll Selection
    func deactivate() {
        isActive = false
    }
    
    /// Activate Scroll Selection
    func activate() {
        isActive = true
    }
    
    /// Convert UIBarButtonItems to a style compatible with Scroll Selection
    ///
    /// - Parameter barButtons: Regular Bar Buttons from Navigation Bar
    /// - Returns: UIBarButtonItems that make use of `customView` to show highlights
    static func convertBarButtons(using barButtons: [UIBarButtonItem]) -> [UIBarButtonItem] {
        
        let converted: [UIBarButtonItem] = barButtons.map {
            
            if let image = $0.image?.withConfiguration(UIImage.SymbolConfiguration(scale: .large)) {
                
                let button = UIButton()
                
                button.setImage(image, for: .normal)
                
                button.sizeToFit()
                
                if let target = $0.target, let action = $0.action {
                    button.addTarget(target, action: action, for: .touchUpInside)
                }
                
                // Create shape layer to get fill color
                let layer: CAShapeLayer = .init()
                layer.fillColor = UIColor.systemGray4.cgColor
                
                layer.path = CGPath(roundedRect: .zero,
                                    cornerWidth: .zero,
                                    cornerHeight: .zero,
                                    transform: nil)

                button.layer.insertSublayer(layer, at: 0)
                
                return UIBarButtonItem(customView: button)
                
            } else if let title = $0.title {
                let button = UIButton()
                
                button.setTitle(title, for: .normal)
                
                if let target = $0.target, let action = $0.action {
                    button.addTarget(target, action: action, for: .touchUpInside)
                }
                
                return UIBarButtonItem(customView: button)
            } else {
                return $0
            }
        }
        
        return converted
    }
}

// MARK: - ScrollView Delegate
extension ScrollSelection {
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
                let buttons = getSelectedButtons(atSection: section)

                if let button = buttons.current?.customView as? UIButton,
                   let shapeLayer = button.layer.sublayers?.first as? CAShapeLayer {
                    
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
                        let color = style.color ?? UIColor.systemBlue.withAlphaComponent(0.7)
                        
                        button.tintColor = color
                    }
                    
                    // Adding circular highlight style
                    if let style = circularHighlightStyle {
                        
                        let color = style.color ?? UIColor.red
                        let expands = style.expands ?? true
                        
                        shapeLayer.fillColor = color.cgColor
                        
                        if expands {
                            shapeLayer.path = getExpandingCirclePath(with: multiplier, button: button)
                        } else {
                            shapeLayer.path = getStaticCirclePath(button: button)
                        }
                    }
                }
                
                playHaptics(withSection: section)

                if let button = buttons.previous?.customView as? UIButton {
                    deselectCustomButton(button)
                }

            } else {
                currentSection = -1
                
                let leftBarButtons = parent.navigationItem.leftBarButtonItems?.first
                let rightBarButtons = parent.navigationItem.rightBarButtonItems?.first
                
                if let lastButton = (leftBarButtons ?? rightBarButtons)?.customView as? UIButton {
                    deselectCustomButton(lastButton)
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
        
        let leftBarButtons = parent.navigationItem.leftBarButtonItems ?? []
        let rightBarButtons = parent.navigationItem.rightBarButtonItems ?? []
        
        if let offset = scrollView?.contentOffset.y {
            
            if let section = getCurrentSection(offset) {
                let buttons = rightBarButtons + leftBarButtons
                if let button = buttons[section].customView as? UIButton {
                    if let action = button.actions(forTarget: parent,
                                                   forControlEvent: .touchUpInside)?.first {
                        
                        parent.performSelector(onMainThread: Selector(action),
                                               with: nil,
                                               waitUntilDone: true)
                    }
                }
                
                buttons.forEach {
                    if let button = $0.customView as? UIButton {
                        deselectCustomButton(button)
                    }
                }
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
        
        let leftBarButtons = parent.navigationItem.leftBarButtonItems ?? []
        let rightBarButtons = parent.navigationItem.rightBarButtonItems ?? []
        
        let buttons = rightBarButtons + leftBarButtons
        
        buttons.forEach {
            if let button = $0.customView as? UIButton {
                deselectCustomButton(button)
            }
        }
    }
}

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

// MARK: - Enumerations and Structures
extension ScrollSelection {
    
    /// Customise Scroll Selection using `Style` to change colors, animations and more.
    public struct Style {
        
        public var rawValue: Int
        
        var color: UIColor?
        var expands: Bool?
        
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
        
        /// Changes the Button color during Scroll Selection
        /// - Parameter color: Color to change to. Default is .systemBlue with alpha of 0.7
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
        /// - Returns: A scroll selection style
        public static func circularHighlight(using color: UIColor = .systemGray4,
                                             expands: Bool = true) -> Style {
            var style = Style(rawValue: 1 << 1)
            style.color = color
            style.expands = expands
            
            return style
        }
        
        /// Default scroll selection style
        public static let defaultStyle: [Style] = [highlight(),
                                                 circularHighlight()]
    }
    
    
    /// Indicate the side(s) to update UIBarButtonItems using directions
    public struct Direction: OptionSet {
        
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
    
    /// The styles to play the haptic feedback which is used to alert the user of a new selection
    public enum HapticsStyle {
        
        /// Normal Haptic Style
        /// - Parameter style: Feedback style based on UIImpactFeedbackGenerator
        case normal(style: UIImpactFeedbackGenerator.FeedbackStyle = .light)
        
        /// No haptics
        case disabled
        
        /// Default style, Haptic feedback becomes more pronounced as user scrolls up
        ///
        /// ```
        /// Last Button -> First Button
        /// Weak        -> Strong
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
    func createScrollSelection(withOffset offsetMultiplier: CGFloat = 70,
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
