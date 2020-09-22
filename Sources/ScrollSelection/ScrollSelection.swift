import UIKit
import Foundation

@available(iOS 13.0, *)
public extension UIViewController {
    
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
    
    func updateBarButtons(barButtonSide direction: ScrollSelection.Direction = .all) {
        if navigationController != nil {
            
            if direction.contains(.left) {
                let leftBarButtonItems = navigationItem.leftBarButtonItems ?? []
                
                navigationItem.setLeftBarButtonItems(ScrollSelection.convertBarButtons(using: leftBarButtonItems), animated: false)
            }
            
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

@available(iOS 13.0, *)
public class ScrollSelection {
    
    static let edgeOffset: CGFloat = 8
    
    var parent: UIViewController!
    var style: [Style]!
    var offsetMultiplier: CGFloat!
    var scrollView: UIScrollView?
    
    var hapticStyle: HapticsStyle = HapticsStyle.normal(style: .medium)
    var isActive = true
    
    var currentSection: Int = -1
    
    public init(vc: UIViewController,
                selectedStyle: [Style],
                offsetMultiplier: CGFloat,
                scrollView: UIScrollView?) {
        
        self.parent = vc
        self.style = selectedStyle
        self.offsetMultiplier = offsetMultiplier
        self.scrollView = scrollView
    }
    
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
        
        let leftBarButtons = parent.navigationItem.leftBarButtonItems ?? []
        let rightBarButtons = parent.navigationItem.rightBarButtonItems ?? []
        
        if let offset = scrollView?.contentOffset.y {
            
            /// Get section that got selected
            ///
            /// When `section == nil` there is no selection
            if let section: Int = {
                var currentSection = Int(floor(offset / -offsetMultiplier))
                
                let max = leftBarButtons.count + rightBarButtons.count
                
                if currentSection > max {
                    currentSection = max
                } else if currentSection <= 0 {
                    return nil
                }
                
                currentSection -= 1
                
                return currentSection
            }() {
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
                
                if let button = selectedBarButton?.customView as? UIButton,
                   let shapeLayer = button.layer.sublayers?.first as? CAShapeLayer {
                    
                    var multiplier = (offset / -offsetMultiplier) - CGFloat(section + 1)
                    
                    if multiplier > 1 {
                        multiplier = 1
                    }
                    
                    let maxWidth = button.frame.width + ScrollSelection.edgeOffset * 2
                    let maxHeight = button.frame.height + ScrollSelection.edgeOffset * 2
                    
                    let width = maxWidth * multiplier
                    let height = maxHeight * multiplier
                    
                    let xEdgeOffset: CGFloat = -ScrollSelection.edgeOffset + (maxWidth - width) / 2
                    let yEdgeOffset: CGFloat = -ScrollSelection.edgeOffset + (maxHeight - height) / 2
                    
                    let highlightStyle = style.filter {
                        $0.rawValue == 1
                    }.first
                    let circularHighlightStyle = style.filter { $0.rawValue == 2 }.first
                    
                    if let style = highlightStyle {
                        let color = style.color ?? UIColor.systemBlue.withAlphaComponent(0.7)
                        
                        button.tintColor = color
                    }
                    if let style = circularHighlightStyle {
                        // Circular Highlights
                        
                        let color = style.color ?? UIColor.red
                        let expands = style.expands ?? true
                        
                        shapeLayer.fillColor = color.cgColor
                        
                        if expands {
                            shapeLayer.path = CGPath(roundedRect: .init(x: xEdgeOffset,
                                                                        y: yEdgeOffset,
                                                                        width: width,
                                                                        height: height),
                                                     cornerWidth: height / 2,
                                                     cornerHeight: height / 2,
                                                     transform: nil)
                        } else {
                            shapeLayer.path = CGPath(roundedRect: .init(x: -ScrollSelection.edgeOffset,
                                                                        y: -ScrollSelection.edgeOffset,
                                                                        width: maxWidth,
                                                                        height: maxHeight),
                                                     cornerWidth: height / 2,
                                                     cornerHeight: height / 2,
                                                     transform: nil)
                        }
                        
                    }
                }
                
                playHaptics(withSection: section)

                if let button = previousBarButton?.customView as? UIButton {
                    deselectCustomButton(button)
                }

            } else {
                currentSection = -1
                
                if let previousButton = (rightBarButtons.first ?? leftBarButtons.first)?.customView as? UIButton {
                    deselectCustomButton(previousButton)
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
        let leftBarButtons = parent.navigationItem.leftBarButtonItems ?? []
        let rightBarButtons = parent.navigationItem.rightBarButtonItems ?? []
        
        if let offset = scrollView?.contentOffset.y {
            
            if let section: Int = {
                var currentSection = Int(floor(offset / -offsetMultiplier))
                
                let max = leftBarButtons.count + rightBarButtons.count
                
                if currentSection > max {
                    currentSection = max
                } else if currentSection <= 0 {
                    return nil
                }
                
                currentSection -= 1
                
                return currentSection
            }() {
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
    
    // TODO: Documentation
    func didEndDecelerating() {
        let leftBarButtons = parent.navigationItem.leftBarButtonItems ?? []
        let rightBarButtons = parent.navigationItem.rightBarButtonItems ?? []
        
        let buttons = rightBarButtons + leftBarButtons
        
        buttons.forEach {
            if let button = $0.customView as? UIButton {
                deselectCustomButton(button)
            }
        }
    }
    
    func deselectCustomButton(_ button: UIButton) {
        if let shapeLayer = button.layer.sublayers?.first as? CAShapeLayer {
            
            button.tintColor = .systemBlue
            
            shapeLayer.path = CGPath(roundedRect: .zero,
                                     cornerWidth: .zero,
                                     cornerHeight: .zero,
                                     transform: nil)
        }
    }
    
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
    
    static func convertBarButtons(using barButtons: [UIBarButtonItem]) -> [UIBarButtonItem] {
        
        let converted: [UIBarButtonItem] = barButtons.map {
            
            if let image = $0.image?.withConfiguration(UIImage.SymbolConfiguration(scale: .large)) {
                
                let button = UIButton()
                
                button.setImage(image, for: .normal)
                
                button.sizeToFit()
                
                if let target = $0.target, let action = $0.action {
                    button.addTarget(target, action: action, for: .touchUpInside)
                }
                
                let layer: CAShapeLayer = .init()
                layer.fillColor = UIColor.systemGray5.cgColor
                
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

extension ScrollSelection {
    public struct Style {
        
        public var rawValue: Int
        
        var color: UIColor?
        var expands: Bool?
        
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
        
        public static func highlight(using color: UIColor = UIColor.systemBlue.withAlphaComponent(0.7)) -> Style {
            var style = Style(rawValue: 1 << 0)
            style.color = color
            
            return style
        }
        
        public static func circularHighlight(using color: UIColor = .systemGray5,
                                             expands: Bool = true) -> Style {
            var style = Style(rawValue: 1 << 1)
            style.color = color
            style.expands = expands
            
            return style
        }
        
        public static let defaultStyle: [Style] = [highlight(),
                                                 circularHighlight()]
    }
    
    public struct Direction: OptionSet {
        
        public var rawValue: Int
        
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
        
        public static let left: Direction  = Direction(rawValue: 1 << 0)
        public static let right: Direction = Direction(rawValue: 1 << 1)
        public static let all: Direction   = [.left, .right]
    }
    
    public enum HapticsStyle {
        
        /// Normal Haptic Style
        case normal(style: UIImpactFeedbackGenerator.FeedbackStyle = .light)
        
        /// No haptics
        case disabled
        
        /// Haptic feedback becomes more pronounced as user scrolls up
        ///
        /// Last Button -> First Button
        ///
        /// Weak        -> Strong
        case variableIncreasing
        
        /// Haptic feedback becomes less pronounced as user scrolls up
        ///
        /// First Button -> Last Button
        ///
        /// Strong       -> Weak
        case variableDecreasing
    }
}
