//
//  WebView.swift
//  ComicApp
//
//  Created by Shivam Parekh on 3/18/22.
//

import Foundation
import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    
    let url: URL
    @Binding var showLoading: Bool
    let webView: WKWebView
    
    init(url: URL, showLoading: Binding<Bool>){
        self.webView = WKWebView()
        self.url = url
        self._showLoading = showLoading
    }
    
    func makeUIView(context: Context) -> some UIView {
        webView.navigationDelegate = context.coordinator
        webView.load(URLRequest(url: url))
        return webView
    }
    func updateUIView(_ uiView: UIViewType, context: Context) {
    }
    
    func makeCoordinator() -> WebViewCoordinator {
        WebViewCoordinator(didStart: {
            showLoading = true
        }, didFinish: {
            showLoading = false
        })
    }
    func goBack(){
        webView.goBack()
    }

    func goForward(){
        webView.goForward()
    }
    
    func refresh() {
        webView.reload()
    }
    
    func goHome() {
        webView.load(URLRequest(url: url))
    }
}



class WebViewCoordinator: NSObject, WKNavigationDelegate {
    
    var didStart: () -> Void
    var didFinish: () -> Void
    
    init(didStart: @escaping () -> Void = {}, didFinish: @escaping () -> Void = {}) {
        self.didStart = didStart
        self.didFinish = didFinish
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        didStart()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        didFinish()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print(error)
    }
    

}







//class ViewController: UIViewController, WKUIDelegate{
//
//    var webView: WKWebView!
//
//    override func loadView(){
//        let webConfiguration = WKWebViewConfiguration()
//        webView = WKWebView(frame: .zero, configuration: webConfiguration)
//        webView.uiDelegate = self
//        view = webView
//    }
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        let myURL = URL(string:"https://www.google.com")
//        let myRequest = URLRequest(url: myURL!)
//        webView.load(myRequest)
//    }
//}
