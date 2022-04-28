//
//  Manganelo.swift
//  ComicApp
//
//  Created by Shivam Parekh on 4/4/22.
//

import Foundation
import Combine
import SwiftUI
import Request

struct RemoteImageView: View {
    @ObservedObject var imageLoader:RemoteImageURL
    @State var image:UIImage = UIImage()
    
    
    init(withURL url:String, refURL:String) {
        imageLoader = RemoteImageURL(imageURL:url, referer:refURL)
    }
    
    
    var body: some View {
        Image(uiImage: image)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onReceive(imageLoader.didChange){ data in
                self.image = UIImage(data: data) ?? UIImage()
            }
    }
}

struct ImageView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(alignment: .leading) {
                RemoteImageView(withURL:"https://v12.mkklcdnv6tempv4.com/img/tab_12/00/00/52/aa951409/chapter_82_ok_lets_stand_up/10-o.jpg",refURL: "https://readmanganato.com/manga-aa951409/chapter-82")
            }
    }
}

