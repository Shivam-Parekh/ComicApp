//
//  ManganeloFuncs.swift
//  ComicApp
//
//  Created by Shivam Parekh on 4/10/22.
//

import Foundation
import Combine
import SwiftUI
import Request
import SwiftSoup

class TabLoader: ObservableObject {
    var linHref: String
    var arrString: [String]
    var pages: Int
    init(indexNum:Int, useURL:String) {
        let start = CFAbsoluteTimeGetCurrent()
        linHref = "https://v12.mkklcdnv6tempv4.com/img/tab_12/00/00/52/aa951409/chapter_82_ok_lets_stand_up/1-o.jpg"
        pages = 2
        arrString = ["null"]
        do {
            //print(useURL)
            let content = try String(contentsOf:URL(string: useURL)!)
            
            let doc: Document = try SwiftSoup.parse(content)
            let main: Elements = try doc.select("img[src$=.jpg]")
            let linkP: Element =  main.get(indexNum)
            linHref = try linkP.attr("src")
            //print(linHref)
            pages = main.count
            print(String(pages) + " amount")
            for k in (0...pages-1){
                arrString.append(try main.get(k).attr("src"))
            }
            //print(CFAbsoluteTimeGetCurrent() - start)
        }
        catch let error {
            print(error)
        }
    }
}

class Chapter: ObservableObject{
    var num: Int
    var tabrefURL: String
    @Published var imageURL: [String]
    
    init(tabrefURL:String){
        self.num = 0;
        self.tabrefURL = "https://readmanganato.com/manga-aa951409/chapter-523"
        self.imageURL = ["nil"]
        self.tabrefURL = tabrefURL
        let temp = TabLoader(indexNum:1,useURL: tabrefURL)
        self.num = temp.pages - 1
        //print(num)
        self.imageURL = temp.arrString
    }
    func changeChapter(tabrefURL:String){
        self.tabrefURL = tabrefURL
        let temp = TabLoader(indexNum:1,useURL: tabrefURL)
        self.num = temp.pages
        //print(num)
        self.imageURL = temp.arrString
    }
}

func getURLSession(withURL:String, refURL:String) -> URLRequest{
    guard let url = URL(string: withURL) else { return URLRequest(url: URL(string:"https://picsum.photos/200")!)}
    
    var request = URLRequest(url: url)
    request.setValue(refURL, forHTTPHeaderField: "Referer")
    return request
}

class RemoteImageURL: ObservableObject {
    var didChange = PassthroughSubject<Data, Never>()
    @Published var data = Data() {
        didSet {
            didChange.send(data)
        }
    }
    init(imageURL: String, referer: String) {
        guard let url = URL(string: imageURL) else { return }
        
        var request = URLRequest(url: url)
        request.setValue(referer, forHTTPHeaderField: "Referer")

        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else { return }
            
            DispatchQueue.main.async { self.data = data }

            }.resume()
    }
}

func stringOfNextChapter(useThis:String, chapters:[String]) -> String{
    var x = 0
    x = chapters.firstIndex(of: useThis)!
    return chapters[x-1]
}

func stringOfLastChapter(useThis:String, chapters:[String]) -> String{
    var x = 0
    x = chapters.firstIndex(of: useThis)!
    return chapters[x+1]
}

func stringOfChapterNumber(useThis:String) -> String{
    let x = useThis.lastIndex(of: "-")!
    var y = useThis[x...]
    y.remove(at: y.startIndex)
    return String(y)
}

func stringOfUpdate(useThis:String) -> String{
    let x = useThis.lastIndex(of: " ")!
    return String(useThis[..<x])
}



