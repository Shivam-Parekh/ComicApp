//
//  NetworkManager.swift
//  ComicApp
//
//  Created by Shivam Parekh on 3/26/22.
//

import Combine
import SwiftUI

class NetworkManager: ObservableObject {
  var didChange = PassthroughSubject<NetworkManager, Never>()
  var comic = ListView(results: []){
    didSet {
      didChange.send(self)
    }
  }
  
  init() {
    guard let url = URL(string: "https://api.themoviedb.org/3/discover/movie?sort_by=popularity.desc&api_key=<API_KEY>") else { return }
    URLSession.shared.dataTask(with: url){ (data, _, _) in
      guard let data = data else { return }
      let comic = try! JSONDecoder().decode(ListView.self, from: data)
      DispatchQueue.main.async {
        self.comic = comic
      }
    }.resume()
  }
}
