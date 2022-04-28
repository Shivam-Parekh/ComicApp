//
//  WebView.swift
//  ComicApp
//
//  Created by Shivam Parekh on 3/18/22.
//

import Foundation
import SwiftUI
import WebKit

class WebStateModel: ObservableObject {
    @Published var url: URL? = URL(string: "https://www.google.com")
    
    func updateUrl(_ str: String) {
        if let theUrl = URL(string: "https://" + WebStateModel.stripHttps(str)) {
            url = theUrl
        }
    }
    
    static func stripHttps(_ str: String) -> String {
        var txt = str.trimmingCharacters(in: .whitespaces)
        if txt.starts(with: "https://") {
            txt = String(txt.dropFirst(8))
        }
        return txt
    }
}

struct WebView: UIViewRepresentable {
    
    @ObservedObject var webModel: WebStateModel
    
    let wkWebview = WKWebView()
    
    func makeUIView(context: Context) -> WKWebView {
        if let theUrl = webModel.url {
            let request = URLRequest(url: theUrl, cachePolicy: .returnCacheDataElseLoad)
            wkWebview.load(request)
        }
        return wkWebview
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        if let theUrl = webModel.url {
            let request = URLRequest(url: theUrl, cachePolicy: .returnCacheDataElseLoad)
            uiView.load(request)
        }
    }
    func refresh() {
        wkWebview.reload()
    }
    
    func goBack() {
        guard wkWebview.canGoBack else { return }
        wkWebview.goBack()
        refresh()
    }
    
    func goForward() {
        guard wkWebview.canGoForward else { return }
        wkWebview.goForward()
        refresh()
    }
}
