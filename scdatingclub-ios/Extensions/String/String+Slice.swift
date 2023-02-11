//
//  String+Slice.swift
//  scdatingclub-ios
//
//  Created by Adam Novak on 2023/02/11.
//

import Foundation

extension String {
    
    func slice(from: String, to: String) -> String? {
        guard let rangeFrom = range(of: from)?.upperBound else { return nil }
        guard let rangeTo = self[rangeFrom...].range(of: to)?.lowerBound else { return nil }
        return String(self[rangeFrom..<rangeTo])
    }
    
}
