//
//  ListGistsInteractorTests.swift
//  Gister
//
//  Created by Raymond Law on 10/12/17.
//  Copyright (c) 2017 Clean Swift LLC. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

@testable import Gister
import XCTest

class ListGistsInteractorTests: XCTestCase
{
  // MARK: Subject under test
  
  var sut: ListGistsInteractor!
  
  // MARK: Test lifecycle
  
  override func setUp()
  {
    super.setUp()
    setupListGistsInteractor()
  }
  
  override func tearDown()
  {
    super.tearDown()
  }
  
  // MARK: Test setup
  
  func setupListGistsInteractor()
  {
    sut = ListGistsInteractor()
  }
  
  // MARK: Test doubles
  
  class ListGistsWorkerSpy: ListGistsWorker
  {
    let gists = [Seeds.Gists.text, Seeds.Gists.html]
    
    var fetchWithCompletionHandlerCalled = false
    var fetchWithDelegateCalled = false
    
    override func fetch(completionHandler: @escaping ([Gist]) -> Void)
    {
      fetchWithCompletionHandlerCalled = true
      completionHandler(gists)
    }
    
    override func fetch()
    {
      fetchWithDelegateCalled = true
      delegate?.listGistsWorker(listGistsWorker: self, didFetchGists: gists)
    }
  }
  
  class ListGistsPresentationLogicSpy: ListGistsPresentationLogic
  {
    var presentFetchedGistsCalled = false
    
    func presentFetchedGists(response: ListGists.FetchGists.Response)
    {
      presentFetchedGistsCalled = true
    }
  }
  
  // MARK: Tests
  
  // MARK: Block implementation
  
  func testFetchGistsShouldAskWorkerToFetchGistsWithBlock()
  {
    guard sut.asyncOpKind == .block else { return }
    
    // Given
    let listGistsWorkerSpy = ListGistsWorkerSpy()
    sut.listGistsWorker = listGistsWorkerSpy
    
    // When
    let request = ListGists.FetchGists.Request()
    sut.fetchGists(request: request)
    
    // Then
    XCTAssertTrue(listGistsWorkerSpy.fetchWithCompletionHandlerCalled, "fetchGists(request:) should ask the worker to fetch gists")
  }
  
  func testFetchGistsShouldAskPresenterToFormatGists()
  {
    // Given
    let listGistsWorkerSpy = ListGistsWorkerSpy()
    sut.listGistsWorker = listGistsWorkerSpy
    let listGistsPresentationLogicSpy = ListGistsPresentationLogicSpy()
    sut.presenter = listGistsPresentationLogicSpy
    
    // When
    let request = ListGists.FetchGists.Request()
    sut.fetchGists(request: request)
    
    // Then
    XCTAssertTrue(listGistsPresentationLogicSpy.presentFetchedGistsCalled, "fetchGists(request:) should ask the presenter to format gists")
  }
  
  // MARK: Delegate implementation
  
  func testFetchGistsShouldAskWorkerToFetchGistsWithDelegate()
  {
    guard sut.asyncOpKind == .delegate else { return }
    
    // Given
    let listGistsWorkerSpy = ListGistsWorkerSpy()
    sut.listGistsWorker = listGistsWorkerSpy
    
    // When
    let request = ListGists.FetchGists.Request()
    sut.fetchGists(request: request)
    
    // Then
    XCTAssertTrue(listGistsWorkerSpy.fetchWithDelegateCalled, "fetchGists(request:) should ask the worker to fetch gists")
    XCTAssertNotNil(sut.listGistsWorker.delegate, "fetchGists(request:) should set itself to be the delegate to be notified of fetch results")
  }
  
  func testListGistsWorkerDidFetchGistsShouldAskPresenterToFormatGists()
  {
    // Given
    let listGistsWorkerSpy = ListGistsWorkerSpy()
    sut.listGistsWorker = listGistsWorkerSpy
    let listGistsPresentationLogicSpy = ListGistsPresentationLogicSpy()
    sut.presenter = listGistsPresentationLogicSpy
    
    // When
    sut.listGistsWorker(listGistsWorker: listGistsWorkerSpy, didFetchGists: listGistsWorkerSpy.gists)
    
    // Then
    XCTAssertTrue(listGistsPresentationLogicSpy.presentFetchedGistsCalled, "listGistsWorker(listGistsWorker:didFetchGists:) should ask the presenter to format gists")
  }
}
