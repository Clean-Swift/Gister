//
//  Gist.swift
//  Gister
//
//  Created by Raymond Law on 10/21/17.
//  Copyright © 2017 Clean Swift LLC. All rights reserved.
//

import Foundation

struct Gist
{
  var login: String
  var url: String
  var filename: String
  var filetype: String
}

extension Gist: Equatable
{
  static func ==(lhs: Gist, rhs: Gist) -> Bool
  {
    return lhs.login == rhs.login &&
      lhs.url == rhs.url &&
      lhs.filename == rhs.filename &&
      lhs.filetype == rhs.filetype
  }
}

extension Gist: Hashable
{
  var hashValue: Int
  {
    return login.hashValue
  }
}
