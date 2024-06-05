//
//  utils.swift
//  Coffee Tracker iOS
//
//  Created by lena on 02/06/2024.
//

import Foundation

extension String {
    
    /// Convert a one- or two-integer version number to a three-integer number.
    /// For example, `"1.0"` is converted to `"1.0.0"`.
    /// Note: The output of is function will be a valid SemVer number or `nil`.
    /// SeeAlso: www.semver.org
    func toThreePointVersionNumber() -> String? {
        
        /* Note to the developer:
         *
         * The SemVer format optionally includes pre-release and build metadata
         * information (see www.semver.org). You could modify this function to
         * accept and validate this optional information before providing the value
         * to Split Suite.
        */
        
        if #available(iOS 16, *) {
            
            // validate and capture version integers
            let versionRegex = /(?<major>([1-9]\d*|0))(\.(?<minor>([1-9]\d*|0)))?(\.(?<patch>([1-9]\d*|0)))?/
            
            if let result = try? versionRegex.wholeMatch(in: self) {
                let minor = result.minor ?? "0"
                let patch = result.patch ?? "0"
                
                return "\(result.major).\(minor).\(patch)"
            }
            
        } else {
            
            // capture version integers
            let integers = self.split(separator:".")
            
            var ints = integers
            if (ints.count < 2) { ints.append("0") }
            if (ints.count < 3) { ints.append("0") }
            
            if (ints[0].isNumber && ints[1].isNumber && ints[2].isNumber) { // validate
                return "\(ints[0]).\(ints[1]).\(ints[2])"
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
