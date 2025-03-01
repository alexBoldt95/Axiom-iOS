//
//  ContentView.swift
//  Axiom-iOS
//
//  Created by Alexander Boldt on 2/8/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        GameView(secretWordList: Array(repeating: "AXIOM", count: 6))
    }
}

#Preview {
    ContentView()
}
