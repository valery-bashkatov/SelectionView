//
//  SelectionView.swift
//  SelectionView
//
//  Created by Valery Bashkatov on 10.08.16.
//  Copyright © 2016 Valery Bashkatov. All rights reserved.
//

import UIKit

/**
 The `SelectionView` class provides selection mechanism and container for views that may be selected.
 */
public class SelectionView: UIView {
    
    // MARK: - Properties
    
    /// The list of views that can be selected.
    private(set) public var selectableSubviews = Set<UIView /* and Selectable */>()
    
    /// The list of selected views.
    public var selectedSubviews: [UIView] {
        return Array(selectableSubviews).filter {($0 as! Selectable).isSelected}
    }
    
    /// A Boolean value that determines the possibility of multiple views selection.
    public var allowsMultipleSelection = true {
        didSet {
            if allowsMultipleSelection {
                panGestureRecognizer.enabled = true
                multipleSelectionView.hidden = false
            } else {
                panGestureRecognizer.enabled = false
                multipleSelectionView.frame = CGRectZero
                multipleSelectionView.hidden = true
                deselectAll()
            }
        }
    }
    
    /// The view that shows the frame of multiple selection with pan gesture.
    public let multipleSelectionView = UIView()
    
    /// Used to single view selection.
    private let tapGestureRecognizer = UITapGestureRecognizer()
    
    /// Used to multiple views selection.
    private let panGestureRecognizer = UIPanGestureRecognizer()
    
    // MARK: - Initialization
    
    /// :nodoc:
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    /// :nodoc:
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    /// Makes initial setup.
    private func setup() {
        opaque = false
        userInteractionEnabled = true
        allowsMultipleSelection = true
        
        multipleSelectionView.opaque = false
        multipleSelectionView.hidden = false
        multipleSelectionView.userInteractionEnabled = false
        
        addSubview(multipleSelectionView)
        
        tapGestureRecognizer.addTarget(self, action: #selector(selectOne(_:)))
        panGestureRecognizer.addTarget(self, action: #selector(selectMultiple(_:)))
        
        addGestureRecognizer(tapGestureRecognizer)
        addGestureRecognizer(panGestureRecognizer)
    }
    
    // MARK: - Managing Selections
    
    /**
     The action of single (or multiple one by one) view selection.
     
     - parameter tapGestureRecognizer: The `UITapGestureRecognizer` sender instance.
     
     :nodoc:
     */
    @IBAction func selectOne(tapGestureRecognizer: UITapGestureRecognizer) {
        let point = tapGestureRecognizer.locationInView(self)
        
        for selectableView in selectableSubviews where CGRectContainsPoint(selectableView.frame, point) {
            if !allowsMultipleSelection {
                deselectAll()
            }
            
            toggleSelectedState(of: selectableView)
        }
    }
    
    /**
     The action of multiple views selection with pan gesture.
     
     - parameter panGestureRecognizer: The `UIPanGestureRecognizer` sender instance.
     
     :nodoc:
     */
    @IBAction func selectMultiple(panGestureRecognizer: UIPanGestureRecognizer) {
        let originalPoint = panGestureRecognizer.locationInView(self)
        let translatedPoint = panGestureRecognizer.translationInView(self)
        
        switch panGestureRecognizer.state {
        case .Began:
            panGestureRecognizer.setTranslation(CGPointZero, inView: self)
            
        case .Changed:
            let selectionOrigin = CGPoint(x: originalPoint.x - translatedPoint.x, y: originalPoint.y - translatedPoint.y)
            let selectedRect = CGRect(origin: selectionOrigin, size: CGSize(width: translatedPoint.x, height: translatedPoint.y))
            
            multipleSelectionView.frame = selectedRect
            
            for selectableView in selectableSubviews {
                if CGRectIntersectsRect(selectableView.frame, selectedRect) {
                    toggleSelectedState(of: selectableView, to: true)
                } else {
                    toggleSelectedState(of: selectableView, to: false)
                }
            }
            
        default:
            multipleSelectionView.frame = CGRectZero
        }
    }
    
    /// Removes selection from all views.
    public func deselectAll() {
        for selectedView in selectedSubviews {
            toggleSelectedState(of: selectedView, to: false)
        }
    }
    
    /**
     Toggles the selection state of the view.
     
     - parameter selectableView: The view to be toggled.
     - parameter selected: Optional. Toggle to which state: true / false / nil (reverse, default).
     */
    public func toggleSelectedState(of selectableView: UIView, to selected: Bool? = nil) {
        let selectableView = (selectableView as! Selectable)
        
        selectableView.isSelected = selected ?? !selectableView.isSelected
    }
    
    // MARK: - Adding and Removing Subviews
    
    /**
     Adds the view to the array of selectable subviews.
     
     - parameter selectableView: The view to be added.
     */
    public func addSelectableSubview<T where T: UIView, T: Selectable>(selectableView: T) {
        addSubview(selectableView)
    }
    
    /**
     Removes the view from the array of selectable subviews.
     
     - parameter selectableView: The view to be removed.
     */
    public func removeSelectableSubview<T where T: UIView, T: Selectable>(selectableView: T) {
        selectableView.removeFromSuperview()
    }
    
    // MARK: - Handling View-Related Changes
    
    /**
     If the view being added is `Selectable` then add it as selectable view 
     (this allows to add selectable views in the Interface Builder).
     
     :nodoc:
     */
    public override func didAddSubview(subview: UIView /* and? Selectable */) {
        super.didAddSubview(subview)
        
        if subview is Selectable {
            selectableSubviews.insert(subview)
        }
        
        bringSubviewToFront(multipleSelectionView)
    }
    
    /**
     If the view being removed is `Selectable` then remove it from selectable views array too.
     
     :nodoc:
     */
    public override func willRemoveSubview(subview: UIView /* and? Selectable */) {
        super.willRemoveSubview(subview)
        
        if subview is Selectable {
            selectableSubviews.remove(subview)
        }
    }
}
