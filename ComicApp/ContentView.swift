//
//  ContentView.swift
//  ComicApp
//
//  Created by Shivam Parekh on 3/18/22.
//

import SwiftUI

extension View {
    func toAnyView() -> AnyView{
        AnyView(self)
    }
}



struct ContentView: View {
    @StateObject var webModel = WebStateModel()
    @State var text = ""
    @State var webView: WebView?
    var body: some View {
        GeometryReader { geometry in
            ZStack{
                VStack{
                    ZStack{
                    Rectangle().fill(Color.black).frame(width: geometry.size.width, height: geometry.size.height * 0.12);
                        Text("Internal Browser").foregroundColor(.white)
                    }
                        TextField("Enter a URL", text: Binding(
                            get: { text },
                            set: { text = WebStateModel.stripHttps($0) } ), onCommit: {
                                webModel.updateUrl(text)
                            }).textFieldStyle(.roundedBorder)
                        webView
                    Spacer()
                    ZStack{
                    Rectangle().fill(Color.gray).frame(width: geometry.size.width, height: geometry.size.height * 0.12);
                        HStack{
                            Button(action: { webView?.refresh() }) {
                                Image(systemName: "arrow.clockwise.circle")
                            }
                            Button(action: { webView?.goBack() }) {
                                Image(systemName: "arrow.left.circle")
                            }
                            Button(action: { webView?.goForward() }) {
                                Image(systemName: "arrow.right.circle")
                            }
                        }
                    }
                    
                }
            }
            .ignoresSafeArea().onAppear {
                webView = WebView(webModel: webModel)
            }
        }

    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
        }
    }
}
