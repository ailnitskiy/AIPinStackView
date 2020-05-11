import UIKit

protocol AIPinStackViewDelegate: class {
    func pinStackViewChanged(_ pin: String, filled: Bool)
    func customizePinItem(item: UILabel)
}

final class AIPinStackView: UIStackView {
    typealias Item = UILabel
    
    weak var delegate: AIPinStackViewDelegate?
    
    @IBInspectable var numberOfDigits: Int = 4 {
        didSet {
            setup()
        }
    }
    
    var filledItemCollor = UIColor.black
    var clearItemCollor = UIColor.gray
    
    private var loaded = false
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard !loaded else { return }
        
        loaded = true
        setup()
    }
    
    private func setup() {
        arrangedSubviews.forEach({ $0.removeFromSuperview() })
        
        while arrangedSubviews.count < numberOfDigits {
            let sideSize = 58
            let item = Item(frame: CGRect(x: 0, y: 0, width: sideSize, height: sideSize))
            item.textAlignment = .center
            
            delegate?.customizePinItem(item: item)
            addArrangedSubview(item)
            
            let widthConstraint = NSLayoutConstraint(item: item, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: CGFloat(sideSize))
            addConstraints([widthConstraint])
        }
        
        clear()
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(startEditing)))
    }
    
    @objc func startEditing() {
        becomeFirstResponder()
    }
    
    var pin: String {
        var str = ""
        arrangedSubviews.forEach({ view in
            let text = (view as! Item).text ?? ""
            str += text
        })
        
        return str
    }
    
    func clear() {
        arrangedSubviews.forEach { (view) in
            clearItem(view as! Item)
        }
    }
    
    private func clearItem(_ item: Item) {
        item.text = ""
        item.backgroundColor = clearItemCollor
    }
}

extension AIPinStackView: UITextInputTraits {
    var keyboardType: UIKeyboardType {
        get {
            return .numberPad
        }
        set {
            assertionFailure()
        }
    }
}

extension AIPinStackView: UIKeyInput {
    var hasText: Bool {
        for sv in arrangedSubviews {
            let label = sv as! Item
            if label.text != nil && !label.text!.isEmpty {
                return true
            }
        }
        return false
    }
    
    func insertText(_ text: String) {
        if text.count == 1 {
            for sv in arrangedSubviews {
                let label = sv as! Item
                if label.text == nil || label.text!.isEmpty {
                    label.text = text
                    label.backgroundColor = filledItemCollor
                    break
                }
            }
            
        }
        
        delegate?.pinStackViewChanged(pin, filled: pin.count == arrangedSubviews.count)
    }
    
    func deleteBackward() {
        var i = arrangedSubviews.count - 1
        while i >= 0 {
            let label = arrangedSubviews[i] as! Item
            if label.text != nil && !label.text!.isEmpty {
                clearItem(label)
                break
            }
            i -= 1
        }
        
        delegate?.pinStackViewChanged(pin, filled: pin.count == arrangedSubviews.count)
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
}
