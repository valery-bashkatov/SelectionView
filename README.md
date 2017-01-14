# SelectionView
`SelectionView` simplifies implementation of the parent view with selectable child views.

## Requirements
- iOS 9.0+
- Swift 3.0+

## Installation
### Carthage
To integrate `SelectionView` into your project using [Carthage](https://github.com/Carthage/Carthage), specify it in your `Cartfile`:

```
github "valery-bashkatov/SelectionView" ~> 2.0.0
```

And then follow the [instructions](https://github.com/Carthage/Carthage#if-youre-building-for-ios-tvos-or-watchos) to install the framework.

## Documentation
API Reference is located at [http://valery-bashkatov.github.io/SelectionView](http://valery-bashkatov.github.io/SelectionView).

## Usage
```swift
import UIKit
import SelectionView

class SelectableCell: UIView, Selectable {
    
    var isSelected = false {
        didSet {
            if isSelected {
                backgroundColor = UIColor.gray
            } else {
                backgroundColor = UIColor.clear
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        isOpaque = false
        
        layer.borderWidth = 0.5
        layer.borderColor = UIColor(white: 0.8, alpha: 0.5).cgColor
    }
}

class ViewController: UIViewController {

    private var selectionView: SelectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        selectionView = SelectionView(frame: CGRect(x: 50, y: 50, width: 200, height: 200))
        
        selectionView.multipleSelectionView.layer.borderWidth = 0.5
        selectionView.multipleSelectionView.layer.borderColor = UIColor(white: 0.7, alpha: 1).cgColor
        selectionView.multipleSelectionView.backgroundColor = UIColor(white: 0.9, alpha: 0.5)
        
        for column in 0..<4 {
            for row in 0..<4 {
                let selectableCell = SelectableCell(frame: CGRect(x: (row % 4) * 50,
                                                                  y: (column % 4) * 50,
                                                                  width: 50,
                                                                  height: 50))
                
                selectionView.addSelectableSubview(selectableCell)
            }
        }
        
        view.addSubview(selectionView)
    }
}
```