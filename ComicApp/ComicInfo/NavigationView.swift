//
//  NavigationView.swift
//  ComicApp
//
//  Created by Shivam Parekh on 3/28/22.
//

import SwiftUI
import SwiftSoup


struct ComicInfo: Hashable{
    let nameOfComic: String
    let imageOfComic: String
    let linkToComic: String
    
    init(nameOfComic:String,imageOfComic:String,linkToComic:String){
        self.nameOfComic=nameOfComic
        self.imageOfComic=imageOfComic
        self.linkToComic=linkToComic
    }
    
}

class ScrollItems: ObservableObject {
    @Published var comicsList = [ComicInfo]()
    @Published var isLoading = false
    var pages: Int
    var canLoadMorePages = true
    var mangaPages = 10000
    init(useURL:String, useSearch:Bool) {
        let start = CFAbsoluteTimeGetCurrent()
        comicsList = [ComicInfo(nameOfComic: "null",imageOfComic: "null",linkToComic: "null")]
        pages = 0
        if useSearch{
            search(useURL: useURL)
        }
        else{
            latest(useURL: useURL)
        }
    }
    
    
    func latest(useURL:String){
        do {
            guard !isLoading
                    && canLoadMorePages else {
                  return
                }
            //print(useURL)
            isLoading = true
            let content = try String(contentsOf:URL(string: useURL)!)
            
            let doc: Document = try SwiftSoup.parse(content)
            if mangaPages == 10000{
                let lastPageClass: Elements = try doc.getElementsByClass("page-blue page-last")
                if lastPageClass.count == 0{
                        self.mangaPages = 1
                }
                else{
                    let lastPageURL = try lastPageClass.get(0).attr("href")
                    let lastIndexFirst = lastPageURL.lastIndex(of: "/")
                    let lastIndexLast = lastPageURL.lastIndex(of: "?")!
                    let stringOfLastPage = lastPageURL[lastIndexFirst!..<lastIndexLast]
                    print(stringOfLastPage)
                    self.mangaPages = Int(stringOfLastPage.dropFirst())!
                }
                    
            }
            let main: Elements = try doc.getElementsByClass("content-genres-item")
            //print(main.count)
            //print(linHref)
            pages = main.count
            //print(String(pages) + " amount")
            if pages == 0{
                return
            }
            for k in (0...pages-1){
                comicsList.append(ComicInfo(nameOfComic:try main.get(k).getElementsByClass("genres-item-img").attr("title"),imageOfComic: try main.get(k).getElementsByClass("img-loading").attr("src")  ,linkToComic: try main.get(k).getElementsByClass("genres-item-img").attr("href")))

                
            }
            if(comicsList[0].nameOfComic == "null"){
                comicsList.removeFirst()
            }
            //print(comicsList)
            //print(comicsList.count)
            isLoading = false
            //print(CFAbsoluteTimeGetCurrent() - start)
        }
        catch let error {
            isLoading = false
            print(error)
        }
    }
    
    func search(useURL:String){
        do {
            guard !isLoading && canLoadMorePages else {
                  return
                }
            isLoading = true
            //print(useURL)
            var temp = useURL
            temp = useURL.replacingOccurrences(of: " ", with: "_")
            temp = "https://manganato.com/search/story/" + temp
            print(temp)
            let content = try String(contentsOf:URL(string: temp)!)
            
            let doc: Document = try SwiftSoup.parse(content)
            if mangaPages == 10000{
                let lastPageClass: Elements = try doc.getElementsByClass("page-blue page-last")
                if lastPageClass.count == 0{
                        self.mangaPages = 1
                        canLoadMorePages = false
                }
                else{
                    let lastPageURL = try lastPageClass.get(0).attr("href")
                    let lastIndex = lastPageURL.lastIndex(of: "=")
                    let stringOfLastPage = lastPageURL[lastIndex!...]
                    self.mangaPages = Int(stringOfLastPage.dropFirst())!
                }
                    
            }
            let main: Elements = try doc.getElementsByClass("search-story-item")
            print(main.count)
            //print(linHref)
            pages = main.count
            print(String(pages) + " amount")
            if pages == 0{
                return
            }
            for k in (0...pages-1){
                comicsList.append(ComicInfo(nameOfComic:try main.get(k).getElementsByClass("a-h text-nowrap item-title").attr("title"),imageOfComic: try main.get(k).getElementsByClass("img-loading").attr("src")  ,linkToComic: try main.get(k).getElementsByClass("a-h text-nowrap item-title").attr("href")))

                
            }
            if(comicsList[0].nameOfComic == "null"){
                comicsList.removeFirst()
            }
            print(comicsList)
            print(comicsList.count)
            isLoading = false
            
            //print(CFAbsoluteTimeGetCurrent() - start)
        }
        catch let error {
            isLoading = false
            print(error)
        }
    }
    
}

struct SomeView: View {
    @StateObject private var SItems = ScrollItems(useURL: "null", useSearch:false)
    private var urlSearch:String
    private var useSearch:Bool
    @State private var firstTime = true
    @State private var pageOfView:Int
    private var threeColumnGrid = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    
    
    init(urlSearch:String, useSearch:Bool){
        self.urlSearch = urlSearch
        self.useSearch = useSearch
        self.pageOfView = 1;
    }
    
    func updateURLPopular() -> String{
        if pageOfView == 1{
            return urlSearch
        }
        let lastIndex = urlSearch.lastIndex(of: "?")
        let firstHalf = urlSearch[..<lastIndex!]
        print(firstHalf)
        let secondHalf = urlSearch[lastIndex!...]
        print(secondHalf)
        let full = String(firstHalf) + "/" + String(pageOfView) + secondHalf
        return full
    }
    
    func updateURLSearch() -> String{
        if pageOfView == 1{
            return urlSearch
        }
        return urlSearch + "?page=" + String(pageOfView)
    }
    var body: some View {
        ZStack{
            ScrollView(.vertical){
                if(SItems.pages != 0){
                    LazyVGrid(columns:threeColumnGrid){
                        ForEach((SItems.comicsList), id: \.self){ i in
                            
                            NavigationLink(destination: NavigationLazyView(ComicView(comicURL: i.linkToComic))){
                                Spacer()
                                NewManga(comics: i)
                                Spacer()
                            }
                        }
                        Color.clear
                            .frame(width: 0, height: 0, alignment: .bottom)
                            .onAppear {
                                if SItems.mangaPages != 1{
                                    pageOfView = pageOfView + 1
                                }
                                if firstTime || SItems.mangaPages >= pageOfView{
                                    if useSearch{
                                        SItems.search(useURL:updateURLSearch())
                                    }
                                    else{
                                        SItems.latest(useURL: updateURLPopular())
                                    }
                                    firstTime = false
                                }
                            }
                        
                    }
                }
                else{
                    Text("No Items Found").onAppear{
                        if(firstTime){
                            if useSearch{
                                SItems.search(useURL:updateURLSearch())
                            }
                            else{
                                SItems.latest(useURL: updateURLPopular())
                            }
                        }
                        firstTime = false
                    }
                }
            }
            if SItems.isLoading {
                ProgressView()
            }
        }
    }
}
