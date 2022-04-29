//
//  ComicView.swift
//  ComicApp
//
//  Created by Shivam Parekh on 3/26/22.
//
import Foundation
import Combine
import SwiftUI
import Request
import SwiftSoup

class ComicLoader: ObservableObject {
    var iconLink: String
    var title: String
    var chapterArrString: [String]
    var altTitle: String
    var author: String
    var status: String
    var updated: String
    var views: String
    var description: String
    
    init(useURL:String) {
        let start = CFAbsoluteTimeGetCurrent()
        iconLink = "null"
        chapterArrString = ["null"]
        title = "null"
        altTitle = "null"
        author = "null"
        status = "null"
        updated = "null"
        views = "null"
        description = "null"
        print("THIS IS RUNNING")
        do {
            let content = try String(contentsOf:URL(string: useURL)!)
            
            let doc: Document = try SwiftSoup.parse(content)
            let chapterElements: Elements = try doc.getElementsByClass("chapter-name text-nowrap")
            print("HERERER")
            for k in chapterElements{
                chapterArrString.append(try k.attr("href"))
            }
            print("NOW EHRERE")
            chapterArrString.removeFirst()
            
            let icon: Elements = try doc.getElementsByClass("img-loading")
            let temp: Element = icon.last()!
            iconLink = try temp.attr("src")
            let titleClass: Elements = try doc.getElementsByClass("story-info-right")
            let titleH: Element = titleClass.first()!
            
            //Get Title
            let titleGetText = try titleH.select("h1")
            self.title = try titleGetText.text()
            print(try titleGetText.text())
            
            //Get Alternate Title, Author, Status
            var getClassInfo = try titleH.getElementsByClass("table-value")
            var tempInt = 1;
            for j in getClassInfo{
                switch tempInt{
                case 1:
                    self.altTitle = try (try j.select("h2")).text()
                case 2:
                    self.author = try (try j.select("a")).text()
                case 3:
                    self.status = try j.text()
                default:
                    continue;
                }
                tempInt += 1
            }
            
            //Get Updated Date, Views
            let classForOtherInfo: Elements = try doc.getElementsByClass("story-info-right-extent")
            let otherInfo: Element = classForOtherInfo.first()!
            getClassInfo = try titleH.getElementsByClass("stre-value")
            tempInt = 1;
            for j in getClassInfo{
                switch tempInt{
                case 1:
                    self.updated = try j.text()
                case 2:
                    self.views = try j.text()
                default:
                    continue;
                }
                tempInt += 1
            }
            
            //Get Description
            let classForDescription: Elements = try doc.getElementsByClass("panel-story-info-description")
            let descriptionInfo: Element = classForDescription.first()!
            self.description = try descriptionInfo.text()
            //print(CFAbsoluteTimeGetCurrent() - start)
        }
        catch let error {
            print(error)
        }
    }
}

struct ComicView: View {
    @Environment(\.managedObjectContext) var moc
    var comic: ListItem
    var comicURL: String
    var iconURL = "null"
    var thisComicLoader:ComicLoader
    var chapters = ["null"]
    init(comicURL:String){
        self.comicURL = comicURL
        self.thisComicLoader = ComicLoader(useURL: comicURL)
        iconURL = thisComicLoader.iconLink
        chapters = thisComicLoader.chapterArrString
        self.comic = ListItem(userId: 1,id: 2,title: "hello",body: "goodbye")
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        UINavigationBar.appearance().standardAppearance = appearance
    }
    var body: some View {
            VStack{
                HStack {
                    AsyncImage(url: URL(string: iconURL)){
                        image in image.resizable()
                    }
                placeholder: {
                    Color.red
                }
                .clipped()
                .frame(width: 100, height: 100)
                    VStack{
                        Text(thisComicLoader.title)
                            .foregroundColor(Color.blue)
                            .lineLimit(nil)
                        Spacer() // help to align the title in the left
                        
                        Text("\(String(thisComicLoader.author))").foregroundColor(Color.gray)
                        Spacer()
                        Text((thisComicLoader.description))
                    }.frame(height:100)
                    
                    
                    Spacer()
                }.padding()
                Button("Add Title"){
                    let comicLURL = ComicListURLS(context: moc)
                    comicLURL.imageURL = thisComicLoader.iconLink
                    comicLURL.title = thisComicLoader.title
                    comicLURL.author = thisComicLoader.author
                    comicLURL.comicURL = comicURL
                    comicLURL.lastUpdated = thisComicLoader.updated
                    try? moc.save()
                }
                ChapterList(chapters:chapters)
            }.navigationBarTitleDisplayMode(.inline)
    }
}

struct ComicView_Previews: PreviewProvider {
    static var previews: some View {
        ComicView(comicURL: "https://readmanganato.com/manga-nr990626")
    }
}
