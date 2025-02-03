//
//  ValidationExtensions.swift
//  BiteBack
//
//  Created by Brian Shon on 2/2/25.
//

//
//  ValidationExtensions.swift
//  BiteBack
//
//  Created by Brian Shon on 2/2/25.
//

import Foundation

extension String {
    /// Checks if the string is a valid email address using a simple regular expression.
    var isValidEmail: Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }
}
