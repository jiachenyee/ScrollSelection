import UIKit
import Foundation

// MARK: - ScrollSelection

/// Select `UIBarButtonItem`s in Navigation Bars by just scrolling up.
///
/// # Quick-Start Guide
/// ```swift
/// var scrollSelection: ScrollSelection!
///
/// override func viewDidLoad() {
///     super.viewDidLoad()
///
///     scrollSelection = createScrollSelection()
/// }
/// ```
///
/// In `UIScrollViewDelegate`,
/// ```swift
/// func scrollViewDidScroll(_ scrollView: UIScrollView) {
///     scrollSelection.didScroll()
/// }
///
/// func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
///     scrollSelection.didEndDragging()
/// }
///
/// func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
///     scrollSelection.didEndDecelerating()
/// }
/// ```
///
@available(iOS 13.0, *)
public class ScrollSelection {
    
    /// Current Edge Offset for Scroll Selection circle highlights
    static let edgeOffset: CGFloat = 8
    
    /// Parent ViewController to be targetted
    open var parent: UIViewController!
    
    /// Current scroll selection style
    open var style: [Style]!
    
    /// Y-Axis offset between selecting buttons
    open var offsetMultiplier: CGFloat!
    
    /// Target ScrollView for Scroll Selection
    open var scrollView: UIScrollView?
    
    /// Haptic feedback styles
    open var hapticStyle: HapticsStyle = .normal
    
    /// Default Tint Color
    open var tintColor: UIColor = .systemBlue
    
    /// Activate or deactivate scroll selection
    var isActive = true
    
    /// To support Haptic Feedback, ensuring that users
    /// do not get spammed with random vibrations
    var currentSection: Int = -1
    
    /// Create custom button sequence
    open var selectionSequence: [SelectionView] = [.rightBarButtons, .leftBarButtons]
    
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
        
        /// Getting all the views
        let views = getViews()
        
        /// Estimated section is based on the current calculated section
        let estimatedSection = Int(floor(offset / -offsetMultiplier))
        
        /// Current section is the actual selected section
        var currentSection = min(views.count, estimatedSection)
        
        // If currentSection is less than or equals zero, it indicates no selection
        if currentSection <= 0 {
            return nil
        }
        
        // Subtract one to make current section start from zero
        currentSection -= 1
        
        return currentSection
    }
    
    /// Getting the selected button based on the current section
    /// - Parameter section: Current selected section
    /// - Returns: The previous and currently selected bar buttons
    func getSelectedViews(atSection section: Int) -> (previous: [UIView], current: UIView?) {
        
        let allViews = getViews()
        
        var selectedView: UIView?
        var previousView: [UIView] = []
        
        selectedView = allViews[section]
        
        if section > 0 {
            previousView.append(allViews[section - 1])
        }
        
        if section + 1 < allViews.count {
            previousView.append(allViews[section + 1])
        }
        
        return (previous: previousView, current: selectedView)
    }
    
    /// Get all scroll selection views
    /// - Returns: Scroll Selection Views
    func getViews() -> [UIView] {
        
        // Getting the navigation item from parent view controller
        let navigationItem = parent.navigationItem
        
        /// Store `UIView`s compatible with Scroll Selection
        var views: [UIView] = []
        
        /// Left bar button items
        let leftBarButtons = navigationItem.leftBarButtonItems?.reversed() ?? []
        
        /// Right bar button items
        let rightBarButtons = navigationItem.rightBarButtonItems ?? []
        
        // Loop through selection sequences, for each, append the
        // corresponding views to the views variable
        selectionSequence.forEach {
            switch $0 {
            case .leftBarButtons, .rightBarButtons:
                
                let barButtons = $0 == .leftBarButtons ? leftBarButtons : rightBarButtons
                
                // Converting the UIBarButtonItems to UIButtons by getting
                // the customViews
                let convertedButtons = barButtons.map {
                    $0.customView as? UIButton
                }.filter {
                    
                    // Filtering out the values that are nil so I can safely
                    // force unwrap to [UIButton]
                    $0 != nil
                    
                } as! [UIButton]
                
                // Adding the convertedButtons to the views
                views += convertedButtons
                
            case .button(let button):
                
                // Adding a custom button (not bar button item)
                views.append(button)
                
            case .searchBar(let searchBar):
                
                // Ensures scroll selection bubble does not get cut off
                searchBar.subviews.first?.clipsToBounds = false
                
                // Adding a search bar
                views.append(searchBar)
            }
        }
        
        return views
    }
    
    /// Get CGPath for static circles (circles that do not expand)
    /// - Parameter button: Button to inherit path
    /// - Returns: CGPath that can be added into the layer
    func getStaticCirclePath(button: UIView) -> CGPath {
        /// Maximum scroll selection bubble width
        let maxWidth = button.frame.width + ScrollSelection.edgeOffset * 2
        
        /// Maximum scroll selection bubble height
        let maxHeight = button.frame.height + ScrollSelection.edgeOffset * 2
        
        /// Corner radii of scroll selectiobn
        let cornerRadii = min(maxHeight / 2, maxWidth / 2)
        
        /// X and Y offsets for scroll selection
        let edgeOffsets = -ScrollSelection.edgeOffset
        
        /// Scroll selection bubble rounded rectangle frame
        let roundedRectFrame = CGRect(x: edgeOffsets,
                                      y: edgeOffsets,
                                      width: maxWidth,
                                      height: maxHeight)
        
        return CGPath(roundedRect: roundedRectFrame,
                      cornerWidth: cornerRadii,
                      cornerHeight: cornerRadii,
                      transform: nil)
    }
    
    /// Get CGPath for expanding circle paths
    /// - Parameters:
    ///   - multiplier: A value, from 0.0 to 1.0 to show how much to expand/shrink path
    ///   - button: Button to inherit the path
    /// - Returns: CGPath that can be added into the layer
    func getExpandingCirclePath(with multiplier: CGFloat, button: UIView) -> CGPath {
        
        /// Maximum scroll selection bubble width
        let maxWidth = button.frame.width + ScrollSelection.edgeOffset * 2
        
        /// Maximum scroll selection bubble height
        let maxHeight = button.frame.height + ScrollSelection.edgeOffset * 2
        
        /// Current scroll selection bubble width
        let width = maxWidth * multiplier
        
        /// Current scroll selection bubble height
        let height = maxHeight * multiplier
        
        /// X edge offsets such that it the bubble is centered in frame
        let xEdgeOffset: CGFloat = -ScrollSelection.edgeOffset + (maxWidth - width) / 2
        
        /// Y edge offsets such that it the bubble is centered in frame
        let yEdgeOffset: CGFloat = -ScrollSelection.edgeOffset + (maxHeight - height) / 2
        
        /// Rounded rectangle frame for scroll selection bubble
        let roundedRectFrame = CGRect(x: xEdgeOffset,
                                      y: yEdgeOffset,
                                      width: width,
                                      height: height)
        
        /// Corner radii of scroll selectiobn
        let cornerRadii = min(height / 2, width / 2)
        
        return CGPath(roundedRect: roundedRectFrame,
                      cornerWidth: cornerRadii,
                      cornerHeight: cornerRadii,
                      transform: nil)
    }
    
    /// Play haptic feedback based on current section
    ///
    /// This function also ensures that haptic feedback is not played
    /// multiple times in the same section
    ///
    /// - Parameter section: Current section user is on
    func playHaptics(withSection section: Int) {
        let styles: [UIImpactFeedbackGenerator.FeedbackStyle] = [.soft, .rigid, .medium, .light, .heavy]
        
        // Index of
        let index = section % styles.count
        
        // If the haptics have already been played, don't play it again
        // otherwise it will cause an unpleasant vibration effect that makes
        // the haptics more of an annoyance
        if currentSection == section { return }
        
        // Update currentSection with section
        currentSection = section
        
        // Switch based on haptic style
        switch hapticStyle {
        case .normal:
            // Handling normal, just use .selectionChanged for a subtle vibration
            UISelectionFeedbackGenerator().selectionChanged()
            
        case .variableDecreasing:
            
            // Reversing the styles to create a decreasing variable style as the user scrolls
            UIImpactFeedbackGenerator(style: styles.reversed()[index]).impactOccurred()
            
        case .variableIncreasing:
            
            // Create an increasing variable style as the user scrolls
            UIImpactFeedbackGenerator(style: styles[index]).impactOccurred()
            
        default:
            break
        }
    }
    
    /// Convert UIBarButtonItems to a style compatible with Scroll Selection
    ///
    /// - Parameter barButtons: Regular Bar Buttons from Navigation Bar
    /// - Returns: UIBarButtonItems that make use of `customView` to show highlights
    static func convertBarButtons(using barButtons: [UIBarButtonItem]) -> [UIBarButtonItem] {
        
        // Converting UIBarButton items
        let converted: [UIBarButtonItem] = barButtons.map {
            
            let button = UIButton()
            
            // Symbol configuration for image
            let symbolConfiguration = UIImage.SymbolConfiguration(scale: .large)
            
            if let image = $0.image?.withConfiguration(symbolConfiguration) {
                
                // If there is an image, create a UIButton just with the image
                button.setImage(image, for: .normal)
                
            } else if let title = $0.title {
                
                // Otherwise, use a title
                button.setTitle(title, for: .normal)
                
            } else {
                
                // Else just return the current bar button,
                // probably won't be compatible with scroll selection
                return $0
            }
            
            // Adding target to the button so an action will be called
            // when the new button gets selected
            if let target = $0.target, let action = $0.action {
                button.addTarget(target, action: action, for: .touchUpInside)
            }
            
            // Setting button size to be exactly large enough
            button.sizeToFit()
            
            // Create shape layer to get fill color
            let layer: CAShapeLayer = .init()
            
            // Creating an empty path for the shape layer
            layer.path = .zero

            // Adding to sublayer
            button.layer.insertSublayer(layer, at: 0)
            
            return UIBarButtonItem(customView: button)
        }
        
        return converted
    }
}
