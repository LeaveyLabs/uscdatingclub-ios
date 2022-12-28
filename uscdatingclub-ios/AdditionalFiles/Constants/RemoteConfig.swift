//
//  RemoteConfig.swift
//  timewellspent-ios
//
//  Created by Adam Novak on 2022/11/20.
//

import Foundation

enum VersionError: Error {
    case invalidBundleInfo, invalidResponse
}

//        _ = try? isUpdateAvailable { (isUpdateAvailable, error) in
//            if let error = error {
//                print(error)
//            } else if let isUpdateAvailable = isUpdateAvailable {
//                guard isUpdateAvailable else { return }
////                self.wasUpdateFoundAvailable = true
//                //DO SOMETHING SINCE UPDATE IS AVAILABLE
//            }
//        }

func isVersion(_ versionA: String, newerThan versionB: String) -> Bool? {
    print("is version " + versionA + " newer than " + versionB)
    let componentsA: [Int] = versionA.components(separatedBy: ".").compactMap { Int($0) }
    let componentsB: [Int] = versionB.components(separatedBy: ".").compactMap { Int($0) }
    guard componentsB.count == 3, componentsA.count == 3 else { return nil }
    //we need the == check in the following else ifs in case the apple testers are testing on 3.0.0 but 2.9.9 is available in the app store
    if componentsA[0] > componentsB[0]{
        return true
    } else if componentsA[0] == componentsB[0] &&
                componentsA[1] > componentsB[1] {
        return true
    } else if componentsA[0] == componentsB[0] &&
                componentsA[1] == componentsB[1] &&
                componentsA[2] > componentsB[2] {
        return true
    } else {
        return false
    }
}

func isUpdateAvailable(completion: @escaping (Bool?, Error?) -> Void) throws -> URLSessionDataTask {
    guard let info = Bundle.main.infoDictionary,
        let currentVersion = info["CFBundleShortVersionString"] as? String,
        let identifier = info["CFBundleIdentifier"] as? String,
        let url = URL(string: "https://itunes.apple.com/lookup?bundleId=\(identifier)") else {
            throw VersionError.invalidBundleInfo
    }
    let request = URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData) //ignore local cache of old version
    let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
        do {
            if let error = error { throw error }
            guard let data = data else { throw VersionError.invalidResponse }
            let json = try JSONSerialization.jsonObject(with: data, options: [.allowFragments]) as? [String: Any]
            guard let result = (json?["results"] as? [Any])?.first as? [String: Any], let newestVersion = result["version"] as? String else {
                throw VersionError.invalidResponse
            }
            print("VERSIONN", newestVersion, currentVersion)
            let currentComponents: [Int] = currentVersion.components(separatedBy: ".").compactMap { Int($0) }
            let newestComponents: [Int] = newestVersion.components(separatedBy: ".").compactMap { Int($0) }
            guard currentComponents.count == 3, newestComponents.count == 3 else { return }
            //we need the == check in the following else ifs in case the apple testers are testing on 3.0.0 but 2.9.9 is available in the app store
            if newestComponents[0] > currentComponents[0]{
                completion(true, nil)
            } else if newestComponents[0] == currentComponents[0] &&
                    newestComponents[1] > currentComponents[1] {
                completion(true, nil)
            } else if newestComponents[0] == currentComponents[0] &&
                        newestComponents[1] == currentComponents[1] &&
                        newestComponents[2] > newestComponents[2] {
                completion(true, nil)
            } else {
                completion(false, nil)
            }
        } catch {
            completion(nil, error)
        }
    }
    task.resume()
    return task
}
