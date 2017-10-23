//
//  GistAPITest.swift
//  Gister
//
//  Created by Raymond Law on 10/12/17.
//  Copyright © 2017 Clean Swift LLC. All rights reserved.
//

@testable import Gister
import XCTest

// MARK: Test doubles

class URLSessionSpy: URLSession
{
  var dataTaskWithURLCalled = false
  var dataTask = URLSessionDataTaskSpy()
  var data: Data?
  
  override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask
  {
    dataTaskWithURLCalled = true
    completionHandler(data, nil, nil)
    return dataTask
  }
}

class URLSessionDataTaskSpy: URLSessionDataTask
{
  var resumeCalled = false
  
  override func resume()
  {
    resumeCalled = true
  }
}

class GistAPITest: XCTestCase
{
  // MARK: Subject under test
  
  var sut: GistAPI!
  
  // MARK: Test lifecycle
  
  override func setUp()
  {
    super.setUp()
    setupGistAPI()
  }
  
  override func tearDown()
  {
    super.tearDown()
  }
  
  // MARK: Test setup
  
  func setupGistAPI()
  {
    sut = GistAPI()
  }
  
  // MARK: Tests
  
  func testFetchShouldAskURLSessionToFetchGistsFromGitHub()
  {
    // Given
    let sessionSpy = URLSessionSpy()
    sut.session = sessionSpy
    
    // When
    let fetchCompleted = expectation(description: "Wait for fetch to complete")
    sut.fetch { (gists) in
      fetchCompleted.fulfill()
    }
    waitForExpectations(timeout: 5.0, handler: nil)
    
    // Then
    XCTAssertTrue(sessionSpy.dataTaskWithURLCalled, "fetch(completionHandler:) should ask URLSession to fetch gists from GitHub")
    XCTAssertTrue(sessionSpy.dataTask.resumeCalled, "fetch(completionHandler:) should start the data task")
  }
  
  func testFetchShouldParseJSONToGists()
  {
    // Given
    let sessionSpy = URLSessionSpy()
    sut.session = sessionSpy
    sessionSpy.data = Seeds.JSON.data
    
    // When
    var actualGists: [Gist]?
    let fetchCompleted = expectation(description: "Wait for fetch to complete")
    sut.fetch { (gists) in
      actualGists = gists
      fetchCompleted.fulfill()
    }
    waitForExpectations(timeout: 5.0, handler: nil)
    
    // Then
    let expectedGists = [Seeds.Gists.text, Seeds.Gists.html]
    XCTAssertEqual(actualGists!, expectedGists, "fetch(completionHandler:) should return an array of gists if the fetch succeeds")
  }
  
  func testFetchShouldFailGracefully()
  {
    // Given
    let sessionSpy = URLSessionSpy()
    sut.session = sessionSpy
    sessionSpy.data = nil
    
    // When
    var actualGists: [Gist]?
    let fetchCompleted = expectation(description: "Wait for fetch to complete")
    sut.fetch { (gists) in
      actualGists = gists
      fetchCompleted.fulfill()
    }
    waitForExpectations(timeout: 5.0, handler: nil)
    
    // Then
    let expectedGists = [Gist]()
    XCTAssertEqual(actualGists!, expectedGists, "fetch(completionHandler:) should return an empty array if the fetch fails")
  }
}
