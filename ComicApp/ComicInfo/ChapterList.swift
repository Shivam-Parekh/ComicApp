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
    var chapters: [ChapterInfo]
    @State var isLoading = false
    
    init(chapters:[ChapterInfo]){
        self.chapters = chapters.reversed()
        print(chapters)
    }
    
    func canUseFirst(index:ChapterInfo) -> Int{
        var x = 0
        x = chapters.firstIndex(of: index)!
        if x == 0{
            return 1
        }
        return 0
    }
    
    func canUseLast(index:ChapterInfo) -> Int{
        var x = 0
        x = chapters.firstIndex(of: index)!
        var pages = 0
        do{
            let content = try String(contentsOf:URL(string: index.chapterArrString)!)
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
    
    func chapterList(chapterObj:[ChapterInfo]) -> [String]{
        var k = ["null"]
        for j in chapterObj{
            k.append(j.chapterArrString)
        }
        print(k)
        return k
    }
    
    var body: some View {
        Group{
            if isLoading{
                ActivityIndicatorView(isVisible: $isLoading, type: .default)
            }
            else{
                List {
                    ForEach(chapters.reversed()) { index in
                            NavigationLink(destination: NavigationLazyView(TabofView(tabrefURL: index.chapterArrString, chapters: chapterList(chapterObj: chapters), j: canUseFirst(index: index), k: canUseLast(index: index)))){
                                HStack{
                                Text("Chapter " + stringOfChapterNumber(useThis: index.chapterArrString))
                                Spacer()
                                    Text(stringOfUpdate(useThis: index.chapterUpdate)).foregroundColor(Color.gray)
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
        ChapterList(chapters: [ChapterInfo(chapterArrString: "Hi", chapterUpdate: "How are you"),ChapterInfo(chapterArrString: "Hi", chapterUpdate: "How are you")])
    }
}
