//
//  BasicAPI.swift
//  scdatingclub-ios
//
//  Created by Kevin Sun on 12/29/22.
//

import Foundation

var AUTHTOKEN = ""

func setGlobalAuthToken(token:String) {
    AUTHTOKEN = token
}

func getGlobalAuthToken() -> String {
    return AUTHTOKEN
}

func isSuccess(statusCode:Int) -> Bool {
    return (200...299).contains(statusCode)
}

func isClientError(statusCode:Int) -> Bool {
    return (400...499).contains(statusCode)
}

func isServerError(statusCode:Int) -> Bool {
    return (500...599).contains(statusCode)
}

enum HTTPMethods: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case PATCH = "PATCH"
    case DELETE = "DELETE"
}

class BasicAPI {
    static func filterBasicErrors(data: Data, response: HTTPURLResponse) throws {
        let clientError = (400...499).contains(response.statusCode)
        let serverError = (500...599).contains(response.statusCode)
        
        if clientError {
            if response.statusCode == 401 {
                throw APIError.Unauthorized
            }
            else if response.statusCode == 403 {
                throw APIError.Forbidden
            }
            else if response.statusCode == 404 {
                throw APIError.NotFound
            }
            else if response.statusCode == 408 {
                throw APIError.Timeout
            }
            else if response.statusCode == 429 {
                throw APIError.Throttled
            }
        } else if serverError {
            throw APIError.ServerError
        }
    }
    
    static func runRequest(request:URLRequest) async throws -> (Data, HTTPURLResponse) {
        return try await withCheckedThrowingContinuation({ continuation in
            URLSession.shared.dataTask(with: request) { data, response, error in
                guard error == nil else {
                    continuation.resume(throwing: APIError.CouldNotConnect)
                    return
                }
                guard let response = response as? HTTPURLResponse, let data = data else {
                    continuation.resume(throwing: APIError.NoResponse)
                    return
                }
                continuation.resume(returning: (data, response))
            }.resume()
        })
        //ios15+:
//        guard let (data, response) = try? await URLSession.shared.data(for: request) else {
//            throw APIError.CouldNotConnect
//        }
//        if let httpResponse = (response as? HTTPURLResponse) {
//            try filterBasicErrors(data: data, response: httpResponse)
//            return (data, httpResponse)
//        } else {
//            throw APIError.NoResponse
//        }
    }
        
    
    static func formatURLRequest(url:String, method:String, body:Data, headers:[String:String]) throws -> URLRequest {
        guard let serviceUrl = URL(string: url) else {
            print("ERROR FORMATTING URL IN BASIC API:", url)
            throw APIError.CouldNotConnect
        }

        var request = URLRequest(url: serviceUrl)
        request.httpMethod = method
        request.httpBody = body
        for (header, value) in headers {
            request.setValue(value, forHTTPHeaderField: header)
        }
        request.timeoutInterval = Env.Timeout_Duration
        return request
    }
    
    static func basicHTTPCallWithoutToken(url:String, jsonData:Data, method:String) async throws -> (Data, HTTPURLResponse) {
        let request = try formatURLRequest(url: url,
                                       method: method,
                                       body: jsonData,
                                       headers: ["Content-Type": "application/json"])
        let (data, response) = try await runRequest(request: request)
        try filterBasicErrors(data: data, response: response)
        return (data, response)
    }
    
    static func basicHTTPCallWithToken(url:String, jsonData:Data, method:String) async throws -> (Data, HTTPURLResponse) {
        let request = try formatURLRequest(url: url,
                                       method: method,
                                       body: jsonData,
                                       headers: [
                                        "Content-Type": "application/json",
                                        "Authorization": "Token \(getGlobalAuthToken())",
                                       ])
        let (data, response) = try await runRequest(request: request)
        try filterBasicErrors(data: data, response: response)
        return (data, response)
    }
}

