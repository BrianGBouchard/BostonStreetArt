import Foundation
import UIKit

class InfoViewController: UIViewController, UIGestureRecognizerDelegate {

    // MARK: View Controller Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        let gestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(dismissSwipe))
        gestureRecognizer.direction = .down
        self.view.addGestureRecognizer(gestureRecognizer)
    }

    // MARK: Actions

    @IBAction func dismissButton(sender: Any?) {
        self.dismiss(animated: true, completion: nil)
    }

    @objc func dismissSwipe() {
        self.dismiss(animated: true, completion: nil)
    }
}
