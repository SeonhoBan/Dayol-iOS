//
//  String+Extension.swift
//  Dayol-iOS
//
//  Created by 주성민 on 2021/01/07.
//

import UIKit

extension String {

    /// For Localize
    var localized: String {
        return NSLocalizedString(self, tableName: "Localizable", value: self, comment: "")
    }

    func with(arguments: CVarArg) -> String {
        return String(format: self, arguments)
    }

    /// For Date
    static var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    func height(with width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)

        return ceil(boundingBox.height)
    }
}
