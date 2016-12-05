//
//  Selectable.swift
//  SelectionView
//
//  Created by Valery Bashkatov on 10.08.16.
//  Copyright © 2016 Valery Bashkatov. All rights reserved.
//

import Foundation

/**
 All selectable subviews of the `SelectionView` must implement `Selectable` protocol.
 
 - seealso: `SelectionView`
 */
public protocol Selectable: class {
    
    // MARK: - Properties
    
    /// The selection state of view.
    var isSelected: Bool {get set}
}