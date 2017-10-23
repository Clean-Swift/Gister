//
//  GistAPI.swift
//  Gister
//
//  Created by Raymond Law on 10/12/17.
//  Copyright © 2017 Clean Swift LLC. All rights reserved.
//

import Foundation

protocol GistAPIProtocol
{
  func fetch(completionHandler: @escaping ([Gist]) -> Void)
}

class GistAPI: GistAPIProtocol
{
  lazy var session: URLSession = {
    let config = URLSessionConfiguration.default
    return URLSession(configuration: config)
  }()
  
  func fetch(completionHandler: @escaping ([Gist]) -> Void)
  {
    // Reference: https://developer.github.com/v3/gists
    let url = URL(string: "https://api.github.com/gists/public")!
    let task = session.dataTask(with: url) { (data, response, error) in
      if let data = data {
        let json = try! JSONSerialization.jsonObject(with: data, options: .allowFragments)
        let gists = self.parseJSONToGists(json: json)
        DispatchQueue.main.async {
          completionHandler(gists)
        }
      } else {
        DispatchQueue.main.async {
          completionHandler([])
        }
      }
    }
    task.resume()
  }
  
  private func parseJSONToGists(json: Any) -> [Gist]
  {
    var gists = [Gist]()
    
    if let array = json as? [Any] {
      for hash in array {
        var login: String?
        if let hash = hash as? [String: Any] {
          if let owner = hash["owner"] as? [String: Any] {
            login = owner["login"] as? String
          }
        }
        
        var url: String?
        if let hash = hash as? [String: Any] {
          url = hash["html_url"] as? String
        }
        
        var filename: String?
        var filetype: String?
        if let hash = hash as? [String: Any] {
          if let files = hash["files"] as? [String: Any]{
            if let file = files.first?.value as? [String: Any] {
              filename = file["filename"] as? String
              filetype = file["type"] as? String
            }
          }
        }
        
        if let login = login, let url = url, let filename = filename, let filetype = filetype {
          let gist = Gist(login: login, url: url, filename: filename, filetype: filetype)
          gists.append(gist)
        }
      }
    }
    
    return gists
  }
}
