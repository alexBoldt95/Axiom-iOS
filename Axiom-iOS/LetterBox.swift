//
//  LetterBox.swift
//  Axiom-iOS
//
//  Created by Alexander Boldt on 2/8/25.
//

import SwiftUI

struct LetterBox: View {
    var theLetter: String
    var theState: LetterBoxState
    
    var backgroundState: Color {
        switch theState {
        case .Empty:
            return .white
        case .Incorrect:
            return .gray
        case .Position:
            return .yellow
        case .Correct:
            return .green
        case .Error:
            return .red
        }
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .stroke(.black, style: StrokeStyle(lineWidth: 3))
                .aspectRatio(1, contentMode: .fit)
                .background(backgroundState, in: RoundedRectangle(cornerRadius: 10))
            
            Text(theLetter.uppercased())
                .font(.system(size: 60))
                .fontDesign(.rounded)
        }
        .frame(maxWidth: 150, maxHeight: 85)
    }
}

#Preview {
    LetterBox(theLetter: "B", theState: LetterBoxState.Empty)
}
