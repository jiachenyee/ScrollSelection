import XCTest
import UIKit

@testable import ScrollSelection

final class ScrollSelectionTests: XCTestCase {
    
    func testOffsetCalculation() {
        // Creating a sample instance of a view controller
        let vc = UIViewController()
        _ = UINavigationController(rootViewController: vc)
        
        vc.navigationItem.setLeftBarButton(UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.down"),
                                                           style: .plain,
                                                           target: nil,
                                                           action: nil),
                                           animated: false)
        
        vc.navigationItem.setRightBarButton(UIBarButtonItem(image: UIImage(systemName: "scribble"),
                                                            style: .plain,
                                                            target: nil,
                                                            action: nil),
                                            animated: false)
        
        
        // Creating instance of scrollselection
        let scrollSelection = vc.createScrollSelection()
        
        // Test cases
        XCTAssertEqual(scrollSelection.getCurrentSection(-70), 0)
        
        XCTAssertEqual(scrollSelection.getCurrentSection(-999), 1)
        
        XCTAssertEqual(scrollSelection.getCurrentSection(-50), 0)
        
        XCTAssertNil(scrollSelection.getCurrentSection(-49))
        
        XCTAssertNil(scrollSelection.getCurrentSection(0))
        
        XCTAssertNil(scrollSelection.getCurrentSection(-21))
    }

    static var allTests = [
        ("testOffsetCalculation", testOffsetCalculation),
    ]
}
