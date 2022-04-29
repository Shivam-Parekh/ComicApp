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
import SwiftSoup

struct TabofView: View {
    @State private var isNewChapter = true
    @State private var currentImage = 1
    @ObservedObject private var thisChapter:Chapter
    @State private var tabrefURL = ""
    @State private var isHidden = false
    @State private var prevTotalChapNum:Int
    @State private var firstPage:Int
    @State private var lastPage:Int
    @State private var click = false
    @State private var prevTotalChapPages = 100000
    @State private var hitPrev = false
    var colors = ["Red", "Green", "Blue", "Tartan"]
    @State private var selectedColor = "Red"
    private var chapters:[String]

    init(tabrefURL:String, chapters:[String], j:Int, k:Int){
        self.chapters = chapters
        self.tabrefURL = tabrefURL
        self.thisChapter = Chapter(tabrefURL: tabrefURL)
        self.prevTotalChapNum = Chapter(tabrefURL: tabrefURL).num
        self.firstPage = j
        self.lastPage = k
    }
    
    func canUseFirst() -> Bool{
        var x = 0
        x = chapters.reversed().firstIndex(of: tabrefURL)!
        if x == 0{
            return false
        }
        return true
    }
    
    func canUseLast() -> Bool{
        var x = 0
        x = chapters.reversed().firstIndex(of: tabrefURL)!
        if x == chapters.count - 1{
            return false
        }
        return true
    }
    
    func nextChapter() -> some View{
        //isHidden = true
        thisChapter.changeChapter(tabrefURL:
                                    stringOfNextChapter(useThis: tabrefURL, chapters: chapters))
        return  Text("Next Chapter")
    }
    
    func lastChapter() -> some View{
        //isHidden = true
        thisChapter.changeChapter(tabrefURL:
                                    stringOfLastChapter(useThis: tabrefURL, chapters: chapters))
        print("THIS IS CURRENTIMGATE")
        print(currentImage)
        return  Text("Last Chapter")
    }
    
    func getString() -> String{
        if(chapters.firstIndex(of: thisChapter.tabrefURL) == 0){
            return String(currentImage) + "/" + String(lastPage + 1)
        }
        else{
            return String(currentImage) + "/" + String(lastPage)
        }
    }
    
    func getLastPage() -> Int{
        if(chapters.firstIndex(of: thisChapter.tabrefURL) == 0){
            return lastPage + 1
        }
        else{
            return lastPage
        }
    }
    
    var body: some View {
        ZStack{
        VStack{
            if hitPrev && currentImage == 0 && prevTotalChapPages > lastPage{
                Text("MADE ITTTTT").onAppear{
                    hitPrev = false
                    currentImage = lastPage
                }
            }
            
            else if currentImage == (thisChapter.num + 1){
                nextChapter()
            }
            else if currentImage == 0{
                lastChapter()
            }
            else{
                TabView (selection: $currentImage){
                    let _=print(currentImage)
                    ForEach((firstPage...(lastPage + 1)).reversed(), id: \.self){i in
                        
                        if i == thisChapter.num+1{
                            Text("Next Chapter").tag(thisChapter.num + 1)
                        }
                        else if i == 0 {
                            let _=print(currentImage)
                            Text("Last Chapter").tag(0)
                        }
                        else{
                            RemoteImage(source: getURLSession(withURL:thisChapter.imageURL[i], refURL:thisChapter.tabrefURL)).tag(i)
                        }
                    }.onReceive(thisChapter.$imageURL){ k in
                        let _ = print("hit")
                        if currentImage == 0{
                            tabrefURL = stringOfLastChapter(useThis: tabrefURL, chapters: chapters)
                            currentImage = thisChapter.num
                            print("FOLLOWTHIS")
                            let _ = print(currentImage)
                            let _ = print(thisChapter.num)
                            self.prevTotalChapNum = thisChapter.num
                            let _ = print(tabrefURL)
                        }
                        else if currentImage == prevTotalChapNum + 1{
                            tabrefURL = stringOfNextChapter(useThis: tabrefURL, chapters: chapters)
                            currentImage = 1
                            self.prevTotalChapNum = thisChapter.num
                            let _ = print(tabrefURL)
                        }
                        if !isNewChapter{
                        if !canUseFirst(){
                            firstPage = 1
                        }
                        else{
                            firstPage = 0
                        }
                        if !canUseLast(){
                            lastPage = thisChapter.num - 1
                        }
                        else{
                            lastPage = thisChapter.num
                        }
                    }
                        isNewChapter = false
                        //isHidden = false
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never)).disabled(isHidden).onTapGesture{
                    click = !click
                }
            }
        }.navigationBarHidden(!click)
            if click{
                VStack{
                    
                }.navigationBarHidden(!click)
                    .navigationBarTitle(Text(""))
                    .edgesIgnoringSafeArea([.top, .bottom]).toolbar {// 2
                        ToolbarItem(placement: .principal) { // 3
                            Text("Chapter " + stringOfChapterNumber(useThis: tabrefURL)).fixedSize(horizontal: true, vertical: false)
                        }
                        ToolbarItem(placement: .navigation){
                            Menu("Options") {
                                    Button("Refresh") {}
                                    }
                            }
                    
                            ToolbarItemGroup(placement: .bottomBar) { // 3
                                Button("PC") {
                                    currentImage = firstPage
                                    hitPrev = true
                                    prevTotalChapPages = lastPage
                                }
                                Spacer()
                                Button("P"){
                                    if(!(firstPage == currentImage && chapters.firstIndex(of: thisChapter.tabrefURL) == chapters.count-1)){
                                        if(firstPage+1 == currentImage){
                                            hitPrev = true
                                            prevTotalChapPages = lastPage
                                        }
                                        currentImage -= 1
                                    }
                                }
                                Spacer()
                                Menu(content: {
                                    Picker("Item", selection: $currentImage){
                                        ForEach((1...getLastPage()), id: \.self){i in
                                            Text(String(i) + "/" + String(getLastPage()))
                                        }
                                    }
                                }, label: {
                                        Text(getString())
                                    })
                                Spacer()
                                Button("N"){
                                    if(currentImage != lastPage + 1){
                                        currentImage += 1
                                    }
                                }
                                Spacer()
                                Button("NC") {
                                    currentImage = lastPage + 1
                                } // 4
                                
                            }
                        
                    }
            }
        
    }
        
    }
}


