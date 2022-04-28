//
//  GenreView.swift
//  ComicApp
//
//  Created by Shivam Parekh on 4/24/22.
//

import SwiftUI

class Genres: ObservableObject{
    var name: String
    var value: Int
    
    init(name:String, value:Int){
        self.name = name
        self.value = value
    }
}
struct GenreView: View {
    var body: some View {
        GenreButton()
    }
}

struct GenreView_Previews: PreviewProvider {
    static var previews: some View {
        GenreView()
    }
}
