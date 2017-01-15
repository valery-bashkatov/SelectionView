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
open class SelectionView: UIView {
    
    // MARK: - Properties
    
    /// The list of views that can be selected.
    fileprivate(set) open var selectableSubviews = Set<UIView /* and Selectable */>()
    
    /// The list of selected views.
    open var selectedSubviews: [UIView] {
        return Array(selectableSubviews).filter {($0 as! Selectable).isSelected}
    }
    
    /// A Boolean value that determines the possibility of multiple views selection. Default is `false`.
    open var isMultiselectable = false {
        didSet {
            if isMultiselectable {
                panGestureRecognizer.isEnabled = true
                multiselectionView.isHidden = false
            } else {
                panGestureRecognizer.isEnabled = false
                multiselectionView.frame = CGRect.zero
                multiselectionView.isHidden = true
                deselectAll()
            }
        }
    }
    
    /// The view that shows the frame of multiple selection with pan gesture.
    open let multiselectionView = UIView()
    
    /// Used to single view selection.
    fileprivate let tapGestureRecognizer = UITapGestureRecognizer()
    
    /// Used to multiple views selection.
    fileprivate let panGestureRecognizer = UIPanGestureRecognizer()
    
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
    fileprivate func setup() {
        isOpaque = false
        isUserInteractionEnabled = true
        
        isMultiselectable = false
        
        multiselectionView.isOpaque = false
        multiselectionView.isHidden = true
        multiselectionView.isUserInteractionEnabled = false
        
        addSubview(multiselectionView)
        
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
    @IBAction func selectOne(_ tapGestureRecognizer: UITapGestureRecognizer) {
        let point = tapGestureRecognizer.location(in: self)
        
        for selectableView in selectableSubviews where selectableView.frame.contains(point) {
            if !isMultiselectable {
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
    @IBAction func selectMultiple(_ panGestureRecognizer: UIPanGestureRecognizer) {
        let originalPoint = panGestureRecognizer.location(in: self)
        let translatedPoint = panGestureRecognizer.translation(in: self)
        
        switch panGestureRecognizer.state {
        case .began:
            panGestureRecognizer.setTranslation(CGPoint.zero, in: self)
            
        case .changed:
            let selectionOrigin = CGPoint(x: originalPoint.x - translatedPoint.x, y: originalPoint.y - translatedPoint.y)
            let selectedRect = CGRect(origin: selectionOrigin, size: CGSize(width: translatedPoint.x, height: translatedPoint.y))
            
            multiselectionView.frame = selectedRect
            
            for selectableView in selectableSubviews {
                if selectableView.frame.intersects(selectedRect) {
                    toggleSelectedState(of: selectableView, to: true)
                } else {
                    toggleSelectedState(of: selectableView, to: false)
                }
            }
            
        default:
            multiselectionView.frame = CGRect.zero
        }
    }
    
    /// Removes selection from all views.
    open func deselectAll() {
        for selectedView in selectedSubviews {
            toggleSelectedState(of: selectedView, to: false)
        }
    }
    
    /**
     Toggles the selection state of the view.
     
     - parameter selectableView: The view to be toggled.
     - parameter selected: Optional. Toggle to which state: true / false / nil (reverse, default).
     */
    open func toggleSelectedState(of selectableView: UIView, to selected: Bool? = nil) {
        let selectableView = (selectableView as! Selectable)
        
        selectableView.isSelected = selected ?? !selectableView.isSelected
    }
    
    // MARK: - Adding and Removing Subviews
    
    /**
     Adds the view to the array of selectable subviews.
     
     - parameter selectableView: The view to be added.
     */
    open func addSelectableSubview<T>(_ selectableView: T) where T: UIView, T: Selectable {
        addSubview(selectableView)
    }
    
    /**
     Removes the view from the array of selectable subviews.
     
     - parameter selectableView: The view to be removed.
     */
    open func removeSelectableSubview<T>(_ selectableView: T) where T: UIView, T: Selectable {
        selectableView.removeFromSuperview()
    }
    
    // MARK: - Handling View-Related Changes
    
    /**
     If the view being added is `Selectable` then add it as selectable view 
     (this allows to add selectable views in the Interface Builder).
     
     :nodoc:
     */
    open override func didAddSubview(_ subview: UIView /* and? Selectable */) {
        super.didAddSubview(subview)
        
        if subview is Selectable {
            selectableSubviews.insert(subview)
        }
        
        bringSubview(toFront: multiselectionView)
    }
    
    /**
     If the view being removed is `Selectable` then remove it from selectable views array too.
     
     :nodoc:
     */
    open override func willRemoveSubview(_ subview: UIView /* and? Selectable */) {
        super.willRemoveSubview(subview)
        
        if subview is Selectable {
            selectableSubviews.remove(subview)
        }
    }
}
