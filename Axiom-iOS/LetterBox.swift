//
//  LetterBox.swift
//  Axiom-iOS
//
//  Created by Alexander Boldt on 2/8/25.
//

import SwiftUI

struct LetterBox: View {
    let theLetter: String
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .stroke(style: StrokeStyle(lineWidth: 5))
                .frame( maxHeight: .infinity)
                .foregroundStyle(.tint)
                .aspectRatio(1, contentMode: .fit)
            
            Text(theLetter)
                 .font(.system(size: 80))
//               .border(.black)
        }
        .frame(maxWidth: 150, maxHeight: 150)
        
            
    }
}

#Preview {
    LetterBox(theLetter: "B")
}
