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
  
  override func dataTask(with url: URL) -> URLSessionDataTask
  {
    dataTaskWithURLCalled = true
    return dataTask
  }
}

class URLSessionDataTaskSpy: URLSessionDataTask
{
  var resumeCalled = false
  override var taskIdentifier: Int { return 0 }
  
  override func resume()
  {
    resumeCalled = true
  }
}

class GistAPIDelegateSpy: GistAPIDelegate
{
  var gistAPIDidFetchGistsCalled = false
  var gistAPIDidFetchGistsResults: [Gist]?
  
  func gistAPI(gistAPI: GistAPIProtocol, didFetchGists gists: [Gist])
  {
    gistAPIDidFetchGistsCalled = true
    gistAPIDidFetchGistsResults = gists
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
  
  // MARK: - Block implementation
  
  func testFetchShouldAskURLSessionToFetchGistsFromGitHubWithBlock()
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
  
  // MARK: - Delegate implementation
  
  func testFetchShouldAskURLSessionToFetchGistsFromGitHubWithDelegate()
  {
    // Given
    let sessionSpy = URLSessionSpy()
    sut.session = sessionSpy
    
    // When
    sut.fetch()
    
    // Then
    XCTAssertTrue(sessionSpy.dataTaskWithURLCalled, "fetch(completionHandler:) should ask URLSession to fetch gists from GitHub")
    XCTAssertTrue(sessionSpy.dataTask.resumeCalled, "fetch(completionHandler:) should start the data task")
  }
  
  func testURLSessionTaskDidCompleteWithErrorShouldNotifyDelegateWithGistsResults()
  {
    // Given
    let sessionSpy = URLSessionSpy()
    sut.session = sessionSpy
    let gistAPIDelegateSpy = GistAPIDelegateSpy()
    sut.delegate = gistAPIDelegateSpy
    let dataTaskSpy = URLSessionDataTaskSpy()
    let key = String(dataTaskSpy.taskIdentifier)
    sut.results = [key: NSMutableData(data: Seeds.JSON.data)]
    
    // When
    sut.urlSession(sessionSpy, task: dataTaskSpy, didCompleteWithError: nil)
    
    // Then
    let actualGists = gistAPIDelegateSpy.gistAPIDidFetchGistsResults!
    let expectedGists = [Seeds.Gists.text, Seeds.Gists.html]
    XCTAssertTrue(gistAPIDelegateSpy.gistAPIDidFetchGistsCalled, "urlSession(_:task:didCompleteWithError:) should notify the delegate")
    XCTAssertEqual(actualGists, expectedGists, "urlSession(_:task:didCompleteWithError:) should return the correct gists results")
  }
  
  func testURLSessionTaskDidCompleteWithErrorShouldFailGracefully()
  {
    // Given
    let sessionSpy = URLSessionSpy()
    sut.session = sessionSpy
    let gistAPIDelegateSpy = GistAPIDelegateSpy()
    sut.delegate = gistAPIDelegateSpy
    let dataTaskSpy = URLSessionDataTaskSpy()
    let error: Error? = NSError(domain: "GisterAPI", code: 911, userInfo: ["Unit Test" : "No harm done."])

    // When
    sut.urlSession(sessionSpy, task: dataTaskSpy, didCompleteWithError: error)
    
    // Then
    let actualGists = gistAPIDelegateSpy.gistAPIDidFetchGistsResults!
    XCTAssertTrue(gistAPIDelegateSpy.gistAPIDidFetchGistsCalled, "urlSession(_:task:didCompleteWithError:) should notify the delegate")
    XCTAssertTrue(actualGists.isEmpty, "urlSession(_:task:didCompleteWithError:) should return empty results")
  }
}
