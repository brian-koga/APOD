//
//  URLHelper.swift
//  APoD
//
//  Created by Paul Bonamy on 3/23/21.
//

import Foundation

/*
 Extensions are a mechanism to add new functionality to existing types
 
 Unlike subclassing, which creates a new type, an extension adds functionality
 to the existing type, allowing it to be used anywhere the original type
 might be used.
 
 In this case, we're adding the ability to take an existing URL and bolt
 new query items onto the end, which is helpful when dealing with REST-y APIs
 */

extension URL {
    func withQueries(_ queries: [String: String]) -> URL? {
        var components = URLComponents(url: self, resolvingAgainstBaseURL: true)
        components?.queryItems = queries.compactMap
            { URLQueryItem(name: $0.0, value: $0.1) }
        return components?.url
    }
}
