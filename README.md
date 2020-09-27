# ScrollSelection
![Swift Package Manager](https://img.shields.io/badge/Swift%20Package%20Manager-5.2-orange?style=flat-square&logo=swift&colorA=FFFFFF)

Select `UIBarButtonItem`s in Navigation Bars by Scrolling Up.

<img src="Assets/demo.gif" width="500">

No need for *Reachability* or *awkwardly holding your phone to reach a button in the top corner*.

---

## Quick-Start Guide

### In your ViewController's Swift file,
```swift
import ScrollSelection

var scrollSelection: ScrollSelection!

override func viewDidLoad() {
    super.viewDidLoad()
    
    scrollSelection = createScrollSelection() 

    scrollView.delegate = self 
    // If you are using tableViews, use `tableView.delegate = self`
    // If you are using textViews, use `textView.delegate = self`
}
```

### Setting up in ScrollView/TextView/TableView Delegate
```swift
func scrollViewDidScroll(_ scrollView: UIScrollView) {
    scrollSelection.didScroll()
}

func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    scrollSelection.didEndDragging()
}

func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    scrollSelection.didEndDecelerating()
}
```

### Scroll Selection using UIButton/UISearchBar
```swift
                                     // Add a search bar to scrollSelection
scrollSelection.selectionSequence = [.searchBar(mySearchBar), 

                                     // Add a custom button
                                     .button(myButton),
                                     
                                     // Default, right and left bar buttons
                                     .rightBarButtons,
                                     .leftBarButtons]
```

## Customisations and Documentation
> Note: For updated documentation information, make use of the Quick Help section (or ⌥-click the declaration)

### UIViewController Extension (for quick set-up)
<details>
<summary><code>Create Scroll Selection</code></summary>

#### Summary
Set-Up Scroll Selection on this View Controller
  
#### Declaration
```swift
func createScrollSelection(withOffset offsetMultiplier: CGFloat = 70, 
                           usingStyle style: [ScrollSelection.Style] = ScrollSelection.Style.defaultStyle) -> ScrollSelection
```

#### Parameters
- `withOffset offsetMultiplier`
    - Distance between each button selection
    - Default Value: `70`
- `usingStyle style`
    - Scroll Selection Style. Use `ScrollSelection.Style.defaultStyle` for default implementation or remove this parameter
    - Default Value: `ScrollSelection.Style.defaultStyle`
    - Refer to [Style](#scroll-selection-style) for the various style information
    
#### Returns
An instance of Scroll Selection that is already set up

#### Usage
In your `viewDidLoad` function,
```swift
override func viewDidLoad() {
    super.viewDidLoad()
    
    // Default implementation
    scrollSelection = createScrollSelection() 

    // Custom implementation
    scrollSelection = createScrollSelection(withOffset: 70, usingStyle: ScrollSelection.Style.defaultStyle) 
}
```

</details>

<details>
<summary><code>Update Bar Buttons</code></summary>

#### Summary
Update bar buttons with Scroll Selection
  
#### Declaration
```swift
func updateBarButtons(barButtonSide direction: ScrollSelection.Direction = .all)
```

#### Discussion
Call this function whenever a change is made to the navigation bar buttons

#### Parameters
- `barButtonSide direction`
    - `.left` corresponds to the left bar buttons, `.right` corresponds to the right bar buttons, `.all` updates all buttons.
    - Default Value: .all
    - Refer to [Direction](#direction) for the various direction information

#### Usage
After updating left bar button items,
```swift
scrollSelection.updateBarButtons(barButtonSide: .left)
```

</details>

### UIScrollViewDelegate Implementation
<details>
<summary><code>Did Scroll</code></summary>

#### Summary
Update ScrollSelection when the scrollview scrolls
  
#### Declaration
```swift
func didScroll()
```

#### Discussion
Updates scroll selection by highlighting or removing highlights on corresponding buttons

#### Usage
To be called in `scrollViewDidScroll` function that is part of `UIScrollViewDelegate`
```swift
extension ViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollSelection.didScroll()
    }
}
```

</details>

<details>
<summary><code>Did End Dragging</code></summary>

#### Summary
Update ScrollSelection when user stops dragging scrollView
  
#### Declaration
```swift
func didEndDragging()
```

#### Discussion
Called when scrollView is released (ends dragging) and thus, scroll selection will select the corresponding bar button

#### Usage
To be called in `scrollViewDidEndDragging` function that is part of `UIScrollViewDelegate`
```swift
extension ViewController: UIScrollViewDelegate {
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        scrollSelection.didEndDragging()
    }
}
```

</details>

<details>
<summary><code>Did End Decelerating</code></summary>

#### Summary
Update ScrollSelection once the scrollView stops decelerating
  
#### Declaration
```swift
func didEndDecelerating()
```

#### Discussion
Called when scrollView is ends deceerating and thus, scroll selection will reset to original state

#### Usage
To be called in `scrollViewDidEndDecelerating` function that is part of `UIScrollViewDelegate`
```swift
extension ViewController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollSelection.didEndDecelerating()
    }
}
```

</details>

### Customising ScrollSelection

<details>
<summary><code>Offset Multiplier</code></summary>

#### Summary
Y-Axis offset between selecting buttons

#### Declaration
```swift
var offsetMultiplier: CGFloat!
```

#### Discussion
Should be automatically set in by `init` or the [UIViewController Implementation](#uiviewcontroller-extension-for-quick-set-up)

</details>

<details>
<summary><code>Scroll View</code></summary>

#### Summary
Target UIScrollView for Scroll Selection

#### Declaration
```swift
var scrollView: UIScrollView?
```

#### Usage
```swift

```

#### Discussion
Should be automatically set in by `init` or the [UIViewController Implementation](#uiviewcontroller-extension-for-quick-set-up)

Scroll Selection will ignore all scrollViews except for the targetted one.

#### Usage
```swift
scrollSelection.scrollView = myScrollView
```

</details>

<details>
<summary><code>Haptic Style</code></summary>

#### Summary
Haptic feedback styles

#### Declaration
```swift
var hapticStyle: HapticsStyle = .variableIncreasing
```

#### Discussion
It uses `.variableIncreasing` as default value. 

Refer to [HapticsStyle](#haptic-styles) for the various styles

#### Usage
```swift
scrollSelection.hapticStyle = .variableIncreasing
```

</details>

<details>
<summary><code>Style</code></summary>

#### Summary
Current scroll selection style

#### Declaration
```swift
var style: [Style]!
```

#### Discussion
Should be automatically set in by `init` or the [UIViewController Implementation](#uiviewcontroller-extension-for-quick-set-up).

Refer to [Scroll Selection Styles](#scroll-selection-styles) for the various styles

#### Usage
```swift
// Using the default style
scrollSelection.style = ScrollSelection.Style.defaultStyle 

// Using a custom style
scrollSelection.style = [.circularHighlight(using: .systemRed, expands: true)]
```

</details>

### Scroll Selection Styles

<details>
<summary><code>Highlight</code></summary>

#### Summary
Changes the Button tint color during Scroll Selection

#### Declaration
```swift
public static func highlight(using color: UIColor = UIColor.systemBlue.withAlphaComponent(0.7)) -> Style
```

#### Parameters
- `using color`
    - Color to change to
    - Default Value: `.systemBlue` with alpha of 0.7

#### Returns
A scroll selection style

</details>

<details>
<summary><code>Circular Highlight</code></summary>

#### Summary
Adds a circular highlight/background to the button that is being selected

#### Declaration
```swift
public static func circularHighlight(using color: UIColor = .systemGray4,
                                     expands: Bool = true, 
                                     fades: Bool = true) -> Style
```

#### Parameters
- `using color`
    - Color of highlight
    - Default Value: `.systemGray4` with alpha of 0.7
- `expands`
    - If true, circular highlights will expand radially to show emphasis on the button as the user scrolls up. Otherwise, it will stay static and the highlight will not expand.    
-  `fades`
    - If true, circular highlight background will fade as the user scrolls up. Otherwise, it will jump from one to another, without fading.

#### Returns
A scroll selection style

</details>

### Haptic Styles

<details>
<summary><code>Normal</code></summary>

#### Summary
Normal Haptic Style

#### Declaration
```swift
case normal
```

#### Discussion
Normal corresponds to `UISelectionFeedbackGenerator().selectionChanged()`. A more subtle haptic style.

</details>

<details>
<summary><code>Variable Increasing</code></summary>

#### Summary
Default style, 
 feedback becomes more pronounced as user scrolls up

#### Declaration
```swift
case variableIncreasing
```

#### Discussion
```
First Button -> Last Button
Weak         -> Strong
```

</details>

<details>
<summary><code>Variable Decreasing</code></summary>

#### Summary
Haptic feedback becomes less pronounced as user scrolls up

#### Declaration
```swift
case variableDecreasing
```

#### Discussion
```
First Button -> Last Button
Strong       -> Weak
```

</details>

### Direction

<details>
<summary><code>Left</code></summary>

#### Summary
Update Left Bar Buttons

#### Declaration
```swift
public static let left: Direction = Direction(rawValue: 1 << 0)
```

</details>

<details>
<summary><code>Right</code></summary>

#### Summary
Update Right Bar Buttons

#### Declaration
```swift
public static let right: Direction = Direction(rawValue: 1 << 1)
```

</details>

<details>
<summary><code>All</code></summary>

#### Summary
Update Both Left and Right Bar Buttons

#### Declaration
```swift
public static let all: Direction = [.left, .right]
```

</details>

### Activating and Deactivating

<details>
<summary><code>Activate</code></summary>

#### Summary
Activate Scroll Selection

#### Declaration
```swift
func activate()
```

</details>

<details>
<summary><code>Deactivate</code></summary>

#### Summary
Deactivate Scroll Selection

#### Declaration
```swift
func deactivate()
```

</details>
