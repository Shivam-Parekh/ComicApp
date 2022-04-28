//
//  NewManga.swift
//  ComicApp
//
//  Created by Shivam Parekh on 4/14/22.
//

import SwiftUI

struct NewManga: View {
    private var comicAttr: ComicInfo
    
    init(comics:ComicInfo){
        self.comicAttr = comics
    }
    
    var body: some View {
        VStack{
            AsyncImage(url: URL(string:comicAttr.imageOfComic)) { image in
                image
                    .resizable()
                    .scaledToFill().aspectRatio(contentMode: .fit)
            } placeholder: {
                Image("NotHere").resizable().scaledToFill().aspectRatio(contentMode: .fit)
            }
            .frame(width: 100, height: 150)
            Text(comicAttr.nameOfComic + "\n").lineLimit(2)
        }
    }
    
}


