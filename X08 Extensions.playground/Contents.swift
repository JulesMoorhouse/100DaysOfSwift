import UIKit

// Challenge step 1

extension UIView {
    func bounceOut(duration: TimeInterval) {
        UIView.animate(withDuration: duration) { [unowned self] in
            self.transform = CGAffineTransform(scaleX: 0.0001, y: 0.0001)
        }
    }
}

let testView = UIView()
testView.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
print("size width=\(testView.frame.width)")
testView.bounceOut(duration: 10)
print("size width=\(testView.frame.width)")

// Challenge step 2

extension Int {
    func times(_ closure: () -> Void) {
        guard self > 0 else { return }
        
        for _ in 0 ..< self {
            closure()
        }
    }
}

5.times { print("Hello!") }
0.times { print("Hello!") }
10.times { print("Hello!") }
// Challenge step 3

extension Array where Element: Comparable {
    mutating func remove(item: Element) {
        if let index = self.firstIndex(of: item) {
            self.remove(at: index)
        }
    }
}

var arr = ["red", "green", "blue"]
arr.remove(item: "green")
arr.remove(item: "fred")
