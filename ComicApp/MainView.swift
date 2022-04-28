//
//  MainView.swift
//  ComicApp
//
//  Created by Shivam Parekh on 3/23/22.
//

import Foundation
import SwiftUI

struct MainView: View {
    var body: some View {
        TabView{
            Text("First View")
                .font(.title)
                
            Text("Second View")
                .font(.title)
                
            Text("Third View")
                .font(.title)

            ContentView()
                .font(.title)

        }
    }
}


struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MainView()
        }
    }
}
