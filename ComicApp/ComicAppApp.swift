//
//  ComicAppApp.swift
//  ComicApp
//
//  Created by Shivam Parekh on 3/18/22.
//

import SwiftUI

@main
struct ComicAppApp: App {
    @StateObject private var dataController = DataController()
    
    var body: some Scene {
        WindowGroup {
            UserListView().environment(\.managedObjectContext, dataController.container.viewContext)
            //GenreView()
            //SearchView()
            //MainView()
            //ComicView(comicURL: "https://readmanganato.com/manga-aa951409")
        }
    }
}
