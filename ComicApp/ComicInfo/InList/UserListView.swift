//
//  UserListView.swift
//  ComicApp
//
//  Created by Shivam Parekh on 4/28/22.
//

import SwiftUI

class ListInfo: ObservableObject {
    var comicURL: String
    var title: String
    var author: String
    var lastUpdated: String
    var imageURL: String
    
    init(comicURL:String, imageURL: String, title:String, author:String, lastUpdated:String) {
        self.comicURL = comicURL
        self.imageURL = imageURL
        self.title = title
        self.author = author
        self.lastUpdated = lastUpdated
    }
}

struct UserListView: View {
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(sortDescriptors: []) var comicList: FetchedResults<ComicListURLS>
    
    var body: some View {
        List{
            ForEach(comicList, id:\.self){ comic in
            NavigationLink(destination: NavigationLazyView(InListComicView(comicURL: comic.comicURL ?? "nil"))){
                VStack{
                    HStack {
                        AsyncImage(url: URL(string: comic.imageURL ?? "null")){
                            image in image.resizable()
                        }
                    placeholder: {
                        Color.red
                    }
                    .clipped()
                    .frame(width: 100, height: 100)
                        VStack{
                            Text(comic.title ?? "null")
                                .foregroundColor(Color.blue)
                                .lineLimit(nil)
                            Spacer() // help to align the title in the left
                            
                            Text(comic.author ?? "null").foregroundColor(Color.gray)
                        }.frame(height:100)
                        
                        
                        Spacer()
                    }.padding()
                }.navigationBarTitleDisplayMode(.inline)
            }
            }.onDelete(perform: delete)
        }
        
    }
    func delete(at offsets: IndexSet) {
        for index in offsets {
            let comic = comicList[index]
            moc.delete(comic)
        }
        try? moc.save()
    }
}

struct UserListView_Previews: PreviewProvider {
    static var previews: some View {
        UserListView()
    }
}
