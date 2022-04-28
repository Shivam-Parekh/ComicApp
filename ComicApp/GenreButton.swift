//
//  GenreButton.swift
//  ComicApp
//
//  Created by Shivam Parekh on 4/24/22.
//

import SwiftUI
enum GenreState {
    case off, add, remove
}

struct GenreButton: View {
    @State private var didTap:GenreState = GenreState.off
    private func backgroundColor() -> Color {
        switch (didTap) {
        case .off:
            return Color.clear
        case .add:
            return Color.green
        case .remove:
            return Color.red
        }
    }

      var body: some View {
        Button(action: {
            switch self.didTap {
            case .off:
                self.didTap = GenreState.add
            case .add:
                self.didTap = GenreState.remove
            case .remove:
                self.didTap = GenreState.off
            }
        }) {

        Text("My custom button")
            .font(.system(size: 24))
        }
        .frame(width: 300, height: 75, alignment: .center)
        .padding(.all, 20)
        .background(backgroundColor())
      }
}

struct GenreButton_Previews: PreviewProvider {
    static var previews: some View {
        GenreButton()
    }
}
