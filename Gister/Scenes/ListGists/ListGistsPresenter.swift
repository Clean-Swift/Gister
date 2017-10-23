//
//  ListGistsPresenter.swift
//  Gister
//
//  Created by Raymond Law on 10/12/17.
//  Copyright (c) 2017 Clean Swift LLC. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit

protocol ListGistsPresentationLogic
{
  func presentFetchedGists(response: ListGists.FetchGists.Response)
}

class ListGistsPresenter: ListGistsPresentationLogic
{
  weak var viewController: ListGistsDisplayLogic?
  
  // MARK: Fetch Gists
  
  func presentFetchedGists(response: ListGists.FetchGists.Response)
  {
    let displayedGists = convertGists(gists: response.gists)
    let viewModel = ListGists.FetchGists.ViewModel(displayedGists: displayedGists)
    viewController?.displayFetchedGists(viewModel: viewModel)
  }
  
  private func convertGists(gists: [Gist]) -> [ListGists.FetchGists.ViewModel.DisplayedGists]
  {
    return gists.map { ListGists.FetchGists.ViewModel.DisplayedGists(login: $0.login, url: $0.url, filename: $0.filename, filetype: $0.filetype) }
  }
}
