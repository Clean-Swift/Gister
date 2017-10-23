//
//  Seeds.swift
//  Gister
//
//  Created by Raymond Law on 10/20/17.
//  Copyright © 2017 Clean Swift LLC. All rights reserved.
//

@testable import Gister
import XCTest

struct Seeds
{
  struct Gists
  {
    static let text = Gist(login: "amy", url: "https://gist.github.com/rayvinly/27e1cc51efc3a1015a1e", filename: "amy.txt", filetype: "text/plain")
    static let html = Gist(login: "bob", url: "https://gist.github.com/rayvinly/46396696f020c3e0931c", filename: "bob.html", filetype: "text/html")
  }
  
  struct DisplayedGists
  {
    static let text = ListGists.FetchGists.ViewModel.DisplayedGists(login: Gists.text.login, url: Gists.text.url, filename: Gists.text.filename, filetype: Gists.text.filetype)
    static let html = ListGists.FetchGists.ViewModel.DisplayedGists(login: Gists.html.login, url: Gists.html.url, filename: Gists.html.filename, filetype: Gists.html.filetype)
  }
  
  struct JSON {
    static let data: Data =
    {
      let bundle = Bundle(identifier: "com.clean-swift.GisterTests")!
      let path = bundle.path(forResource: "Gist", ofType: "json")!
      let data = FileManager.default.contents(atPath: path)!
      let json = try! JSONSerialization.jsonObject(with: data, options: .allowFragments)
      return data
    }()
  }
}
