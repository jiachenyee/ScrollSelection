//
//  SelectionViews.swift
//  Scroll Selection Demo
//
//  Created by JiaChen(: on 28/9/20.
//

import Foundation
import UIKit

public extension ScrollSelection {
    
    /// Make views compatible with scroll selection
    ///
    /// Default: rightBarButtons, leftBarButtons
    enum SelectionView: Equatable {
        case leftBarButtons
        case rightBarButtons
        case button(_ button: UIButton)
        case searchBar(_ searchBar: UISearchBar)
    }
}
