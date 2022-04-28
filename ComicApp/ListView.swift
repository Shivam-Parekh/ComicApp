//
//  ListView.swift
//  ComicApp
//
//  Created by Shivam Parekh on 3/23/22.
//

import Foundation
import SwiftUI
import CoreLocation

struct ListItem: Decodable {
    var userId: Int
    var id: Int
    var title: String
    var body: String
}

struct ListView: Decodable {
    var results: [ListItem]

}


