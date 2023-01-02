//
//  GenericAPI.swift
//  uscdatingclub-ios
//
//  Created by Adam Novak on 2023/01/02.
//

import UIKit

class GenericAPI {
    
    static func UIImageFromURLString(url:String?) async throws -> UIImage? {
        guard let url = url else { return nil }

        let (data, response) = try await BasicAPI.basicHTTPCallWithoutToken(url: url, jsonData: Data(), method: HTTPMethods.GET.rawValue)
        try UserAPI.filterUserErrors(data: data, response: response)
        return UIImage(data: data)
    }
    
}
