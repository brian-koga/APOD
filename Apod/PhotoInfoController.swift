//
//  PhotoInfoController.swift
//  APoD
//
//  Created by Brian Koga on 4/2/21.
//

import Foundation

/*
 This object exists to abstract away the process of going out to APoD
 and retrieving information about an entry. Things that use it only need
 to know to call fetchPhotoInfo and then use the provided PhotoInfo object
 */

struct PhotoInfoController {
    /*
     We expect the user to hand in a closure (anonymous function) that will
     receive a PhotoInfo object. (PhotoInto?) -> Void is the type signature
     of the closure. Marking it @escaping means that the closure will run
     after the caller returns.
     */
    func fetchPhotoInfo(date : String, completion: @escaping (PhotoInfo?) -> Void) {
        // use the URLHelper extension to build up the right URL
        let baseURL = URL(string: "https://api.nasa.gov/planetary/apod")!
        let query: [String: String] = [
            "api_key" : "sk80zqhiLhfUMtGxisGz41Bo2xALzckmkfqrrSXD",
            "date" : date
        ]
        let url = baseURL.withQueries(query)!
        
        // URLSessions work asynchronously in the background, so we need
        // a closure to actually process their results
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            let jsonDecoder = JSONDecoder()
            if let data = data, // only passes if data exists
               let photoInfo = try? jsonDecoder.decode(PhotoInfo.self, from: data) {
                // do something with decoded data
                completion(photoInfo)
            }
            else {
                // what if we didn't get data or couldn't decode it?
                completion(nil)
            }
        }
        task.resume() // We set up the task, but have to actually run it
    }
}
