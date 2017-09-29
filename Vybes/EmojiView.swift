import UIKit

class EmojiView: UIStackView {
    
    @IBOutlet var contentView: UIStackView!
    
    var selectedVyberIndex: Int?
    var copyOfVyberList: [Vyber]?
    
    @IBOutlet weak var goodVybeButton: UIButton!
    @IBOutlet weak var mediumVybeButton: UIButton!
    @IBOutlet weak var badVybeButton: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("EmojiView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        goodVybeButton.layer.cornerRadius = 5
        mediumVybeButton.layer.cornerRadius = 5
        badVybeButton.layer.cornerRadius = 5
    }
    
    public func selectVyber(vybers: [Vyber], index: Int) {
        selectedVyberIndex = index
        copyOfVyberList = vybers
    }
    
    @IBAction func setVybe(_ sender: UIButton) {
        let emoji = sender.titleLabel!.text
        
        if var vybers = copyOfVyberList {
            vybers[selectedVyberIndex!].setVybe(emoji!)
            self.isHidden = true
            
            NotificationCenter.default.post(name: .UpdateVyberList, object: self, userInfo: ["vybers" : vybers])
        } else {
            print("ERROR: VYBER NOT DEFINED")
            return
        }
    }
}
