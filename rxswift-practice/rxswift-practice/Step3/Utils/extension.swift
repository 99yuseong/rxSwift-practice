//
//  extension.swift
//  rxswift-practice
//
//  Created by 남유성 on 2023/03/29.
//

import UIKit

extension Int {
    func currencyKR() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: NSNumber(value: self)) ?? ""
    }
}

extension UITextView {
    func calcHeight() -> CGFloat {
        guard let text = self.text, let font = self.font else {
            return 0
        }

        let width = bounds.width
        return heightWithConstrainedWidth(text: text,
                                          width: width,
                                          font: font)
    }
}

extension UIViewController {
    func showAlert(_ title: String, _ message: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertVC, animated: true, completion: nil)
    }
}

func heightWithConstrainedWidth(text: String, width: CGFloat, font: UIFont) -> CGFloat {
    let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
    let boundingBox = text.boundingRect(with: constraintRect, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [NSAttributedString.Key.font: font], context: nil)
    return boundingBox.height
}
