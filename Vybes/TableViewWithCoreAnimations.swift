import UIKit

enum Axis {
    case x
    case y
}

class TableViewWithCoreAnimations: UITableView {
    
    func scale(fromValue: Int, toValue: Int) {
        let animation = CABasicAnimation(keyPath: "transform.scale.xy")
        
        animation.duration = 0.4
        animation.fillMode = kCAFillModeForwards;
        animation.isRemovedOnCompletion = false;
        animation.autoreverses = false;
        animation.repeatCount = 0;
        
        let defaultCurve = CAMediaTimingFunction(name: kCAMediaTimingFunctionDefault)
        animation.timingFunction = defaultCurve
        
        animation.fromValue = fromValue
        animation.toValue = toValue
        
        self.layer.add(animation, forKey: "position")
    }
    
    func scale(fromValue: Int, toValue: Int, duration: Double) {
        let animation = CABasicAnimation(keyPath: "transform.scale.xy")
        
        animation.duration = duration
        animation.fillMode = kCAFillModeForwards;
        animation.isRemovedOnCompletion = false;
        animation.autoreverses = false;
        animation.repeatCount = 0;
        
        let defaultCurve = CAMediaTimingFunction(name: kCAMediaTimingFunctionDefault)
        animation.timingFunction = defaultCurve
        
        animation.fromValue = fromValue
        animation.toValue = toValue
        
        self.layer.add(animation, forKey: "position")
    }
    
    func move(fromValue: CGFloat, toValue: CGFloat, axis: Axis) {
        let animation = CABasicAnimation(keyPath: "position")
        
        animation.duration = 0.4
        animation.fillMode = kCAFillModeForwards;
        animation.isRemovedOnCompletion = false;
        animation.autoreverses = false;
        animation.repeatCount = 0;
        
        let defaultCurve = CAMediaTimingFunction(name: kCAMediaTimingFunctionDefault)
        animation.timingFunction = defaultCurve
        
        switch axis {
        case .x:
            animation.fromValue = NSValue(cgPoint: CGPoint(x: self.center.x + fromValue, y: self.center.y))
            animation.toValue = NSValue(cgPoint: CGPoint(x: self.center.x + toValue, y: self.center.y))
        case .y:
            animation.fromValue = NSValue(cgPoint: CGPoint(x: self.center.x, y: self.center.y + fromValue))
            animation.toValue = NSValue(cgPoint: CGPoint(x: self.center.x, y: self.center.y + toValue))
        }
        self.layer.add(animation, forKey: "position")
    }
}

