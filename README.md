# ScrollSelection
![Swift Package Manager](https://img.shields.io/badge/Swift%20Package%20Manager-5.2-orange?style=flat-square&logo=swift&colorA=FFFFFF)

Select `UIBarButtonItem`s in Navigation Bars by Scrolling Up.

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

## Customisations and Documentation
> Note: For updated documentation information, make use of the Quick Help section (or ⌥-click the declaration)

### UIViewController Extension (for quick set-up)
<details>
<summary><code>createScrollSelection</code></summary>

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
    
#### Returns
An instance of Scroll Selection that is already set up

</details>

<details>
<summary><code>updateBarButtons</code></summary>

#### Summary
Update bar buttons with Scroll Selection
  
#### Declaration
```swift
func updateBarButtons(barButtonSide direction: ScrollSelection.Direction = .all)
```

### Discussion
Call this function whenever a change is made to the navigation bar buttons

#### Parameters
- `barButtonSide direction`
    - `.left` corresponds to the left bar buttons, `.right` corresponds to the right bar buttons, `.all` updates all buttons.
    - Default Value: .all

</details>

### UIScrollViewDelegate Implementation
<details>
<summary><code>didScroll</code></summary>

#### Summary
Update ScrollSelection when the scrollview scrolls
  
#### Declaration
```swift
func didScroll()
```

### Discussion
Updates scroll selection by highlighting or removing highlights on corresponding buttons

### Usage
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
<summary><code>didEndDragging</code></summary>

#### Summary
Update ScrollSelection when user stops dragging scrollView
  
#### Declaration
```swift
func didEndDragging()
```

### Discussion
Called when scrollView is released (ends dragging) and thus, scroll selection will select the corresponding bar button

### Usage
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
<summary><code>didEndDecelerating</code></summary>

#### Summary
Update ScrollSelection once the scrollView stops decelerating
  
#### Declaration
```swift
func didEndDecelerating()
```

### Discussion
Called when scrollView is ends deceerating and thus, scroll selection will reset to original state

### Usage
To be called in `scrollViewDidEndDecelerating` function that is part of `UIScrollViewDelegate`
```swift
extension ViewController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollSelection.didEndDecelerating()
    }
}
```

</details>
