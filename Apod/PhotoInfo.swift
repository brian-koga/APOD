//
//  PhotoInfo.swift
//  APoD
//
//  Created by Paul Bonamy on 3/23/21.
//

import Foundation

struct PhotoInfo: Codable {
    var title: String
    var description: String
    var url: URL
    var copyright: String?
    
    /*
     The actual APoD API calls the description "explanation"
     A CodingKey enum tells the decoder how to map the JSON name
     to the internal one
     */
    enum Keys: String, CodingKey {
        case title
        case description = "explanation"
        case url
        case copyright
    }
    
    /*
     You need to provide an init method if either you don't use all of the
     fields available in the data you're decoding (the case here) or if you
     need to do something more complicated with decoding, like post-processing
     or providing default values or something
     */
    init(from decoder: Decoder) throws {
        let valueContainer = try decoder.container(keyedBy: Keys.self)
        self.title = try valueContainer.decode(String.self, forKey: Keys.title)
        self.description = try valueContainer.decode(String.self, forKey: Keys.description)
        self.url = try valueContainer.decode(URL.self, forKey: Keys.url)
        self.copyright = try? valueContainer.decode(String.self, forKey: Keys.copyright)
    }
}
