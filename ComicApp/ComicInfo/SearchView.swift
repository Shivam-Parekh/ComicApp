//
//  SearchView.swift
//  ComicApp
//
//  Created by Shivam Parekh on 4/15/22.
//

import SwiftUI

struct ButtonView: View {
var body: some View {
    Text("Starten")
        .frame(width: 200, height: 100, alignment: .center)
        .background(Color.yellow)
        .foregroundColor(Color.red)
    }
}

struct LazyView<Content: View>: View {
    let build: () -> Content
    init(_ build: @autoclosure @escaping () -> Content) {
        self.build = build
    }
    var body: Content {
        build()
    }
}

struct SearchView: View {
    @State var userText: String = ""
    
    var body: some View {
        TabView{
        NavigationView{
            VStack{
                Spacer()
                NavigationLink(destination: LazyView(SomeView(urlSearch: "https://manganato.com/genre-all?type=topview",useSearch: false))){
                    Spacer()
                    Text("Most Popular")
                        .frame(width: 200, height: 100, alignment: .center)
                        .background(Color.blue)
                        .foregroundColor(Color.black)
                    
                    Spacer()
                }
                Spacer()
                Section(header: Text("Seach For Item").font(.headline)) {
                    HStack{
                        Spacer()
                        Section {
                            TextField("Search...", text: $userText).textFieldStyle(RoundedBorderTextFieldStyle())
                                .modifier(TextFieldClearButton(text: $userText))
                                .multilineTextAlignment(.leading)
                        }
                        
                        Spacer()
                    }
                    NavigationLink(destination: LazyView(SomeView(urlSearch: userText,useSearch: true))){
                        Spacer()
                        Text("Search")
                            .frame(width: 200, height: 30, alignment: .center)
                            .background(Color.blue)
                            .foregroundColor(Color.black)
                        Spacer()
                    }.disabled(userText == "")
                    Spacer()
                }
            }
        }.navigationViewStyle(StackNavigationViewStyle()).tabItem{
            Label("Menu", systemImage: "test")
        }
            Text("HERERER").tabItem{
                Label("Nice", systemImage: "test")
            }
    }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}
