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
  func fetch()
  var delegate: GistAPIDelegate? { get set }
}

protocol GistAPIDelegate
{
  func gistAPI(gistAPI: GistAPIProtocol, didFetchGists gists: [Gist])
}

class GistAPI: NSObject, GistAPIProtocol, URLSessionDataDelegate, URLSessionTaskDelegate
{
  var delegate: GistAPIDelegate?
  lazy var session: URLSession = {
    let config = URLSessionConfiguration.ephemeral
    if let delegate = self.delegate {
      return URLSession(configuration: config, delegate: self, delegateQueue: OperationQueue.main)
    } else {
      return URLSession(configuration: config)
    }
  }()
  private var dataTask: URLSessionDataTask!
  var results = [String: NSMutableData]()
  // Reference: https://developer.github.com/v3/gists
  private let url = URL(string: "https://api.github.com/gists/public")!
  
  // MARK: - Block implementation
  
  func fetch(completionHandler: @escaping ([Gist]) -> Void)
  {
    dataTask = session.dataTask(with: url) { (data, response, error) in
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
    dataTask.resume()
  }
  
  // MARK: - Delegate implementation
  
  func fetch()
  {
    dataTask = session.dataTask(with: url)
    dataTask.resume()
  }
  
  func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data)
  {
    let key = String(dataTask.taskIdentifier)
    var result = results[key]
    if result == nil {
      result = NSMutableData(data: data)
      results[key] = result
    } else {
      result?.append(data)
    }
  }
  
  func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?)
  {
    if let _ = error {
      delegate?.gistAPI(gistAPI: self, didFetchGists: [])
    } else {
      let key = String(task.taskIdentifier)
      if let result = results[key] as Data? {
        let json = try! JSONSerialization.jsonObject(with: result, options: .allowFragments)
        results[key] = nil
        let gists = self.parseJSONToGists(json: json)
        delegate?.gistAPI(gistAPI: self, didFetchGists: gists)
      } else {
        delegate?.gistAPI(gistAPI: self, didFetchGists: [])
      }
    }
  }
  
  // MARK: - Parsing Gist JSON
  
  private func parseJSONToGists(json: Any) -> [Gist]
  {
    var gists = [Gist]()
    
    if let array = json as? [Any] {
      for hash in array {
        
        var login: String?
        var url: String?
        var filename: String?
        var filetype: String?
        
        if let hash = hash as? [String: Any] {
          
          if let owner = hash["owner"] as? [String: Any] {
            login = owner["login"] as? String
          } else {
            login = "no user"
          }
          
          url = hash["html_url"] as? String
          
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
