 //  ChapterList.swift
//  ComicApp
//
//  Created by Shivam Parekh on 4/10/22.
//

import SwiftUI
import Foundation
import Combine
import SwiftUI
import Request
import SwiftSoup
import ActivityIndicatorView

struct NavigationLazyView<Content: View>: View {
    let build: () -> Content
    init(_ build: @autoclosure @escaping () -> Content) {
        self.build = build
    }
    var body: Content {
        build()
    }
}


struct ChapterList: View {
    var chapters: [String]
    @State var isLoading = false
    
    init(chapters:[String]){
        self.chapters = chapters
        print(chapters)
    }
    
    func canUseFirst(index:String) -> Int{
        var x = 0
        x = chapters.reversed().firstIndex(of: index)!
        if x == 0{
            return 1
        }
        return 0
    }
    
    func canUseLast(index:String) -> Int{
        var x = 0
        x = chapters.reversed().firstIndex(of: index)!
        var pages = 0
        do{
            let content = try String(contentsOf:URL(string: index)!)
            let doc: Document = try SwiftSoup.parse(content)
            let main: Elements = try doc.select("img[src$=.jpg]")
            pages = main.count
        }
        catch let error {
            print(error)
        }
        if x == chapters.count - 1{
            return pages - 2
        }
        return pages - 1
    }
    
    var body: some View {
        Group{
            if isLoading{
                ActivityIndicatorView(isVisible: $isLoading, type: .default)
            }
            else{
            List {
                ForEach(chapters, id: \.self) { index in
                    HStack{ 
                        NavigationLink(destination: NavigationLazyView(TabofView(tabrefURL: index, chapters: chapters, j: canUseFirst(index: index), k: canUseLast(index: index)))){
                            Text("Chapter " + stringOfChapterNumber(useThis: index))
                        }
                    }
                }
                }.onDisappear(){
                    print("YUIOYOI")
                    isLoading = false
             }
            }
        }
    }
}

struct ChapterList_Previews: PreviewProvider {
    static var previews: some View {
        ChapterList(chapters: ["Hi", "How are you","Aare YOU READY","s","d","s"])
    }
}
