//
//  StringExtensions.swift
//  BreadcrumbsSwift
//
//  Created by Kevin Finn on 1/12/18.
//  Copyright © 2018 Kevin Finn. All rights reserved.
//

import Foundation

extension String {
        /// This method makes it easier extract a substring by character index where a character is viewed as a human-readable character (grapheme cluster).
        internal func substring(start: Int, offsetBy: Int) -> String? {
            guard let substringStartIndex = self.index(startIndex, offsetBy: start, limitedBy: endIndex) else {
                return nil
            }
            
            guard let substringEndIndex = self.index(startIndex, offsetBy: start + offsetBy, limitedBy: endIndex) else {
                return nil
            }
            
            return String(self[substringStartIndex ..< substringEndIndex])
        }
        
        internal func lastNDigits(_ n: Int) -> String? {
            return substring(start:self.count-n, offsetBy: n)
        }
        
        static func toJSON<T:Encodable>(_ obj: T) throws -> String?{
            return try String(data: JSONEncoder().encode(obj), encoding: String.Encoding.utf8)
        }
        
}