//
//  utils.swift
//  Coffee Tracker iOS
//
//  Created by lena on 02/06/2024.
//

import Foundation
/*
struct RuntimeError: LocalizedError {
    let description: String

    init(_ description: String) {
        self.description = description
    }

    var errorDescription: String? {
        description
    }
}*/

extension String {
    func toThreePointVersionNumber() /*throws*/ -> String? {
        if #available(iOS 16, *) {
            
            // validate and capture version integers
            let versionRegex = /(?<major>([1-9]\d*|0))(\.(?<minor>([1-9]\d*|0)))?(\.(?<patch>([1-9]\d*|0)))?/
            
            if let result = try? versionRegex.wholeMatch(in: self) {
                let minor = result.minor ?? "0"
                let patch = result.patch ?? "0"
                
                return "\(result.major).\(minor).\(patch)"
            } else {
                //throw RuntimeError("Parsing error: Invalid version string: \(self)")
            }
            
        } else {
            let integers = self.split(separator:".")
            
            var ints = integers
            if (ints.count < 2) { ints.append("0") }
            if (ints.count < 3) { ints.append("0") }
            
            if (ints[0].isNumber && ints[1].isNumber && ints[2].isNumber) {
                return "\(ints[0]).\(ints[1]).\(ints[2])"
            } else {
                //throw RuntimeError("Parsing error: Invalid version string: \(self)")
            }
        }
        return nil
    }
}
extension Substring {
    var isNumber: Bool {
        return self.range(
            of: "^([1-9][0-9]*|0)$",
            options: .regularExpression) != nil
    }
}
