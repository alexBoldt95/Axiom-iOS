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
    var fontDesign: Font.Design = .rounded
    
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
            
            // TODO dynamically size font to container
            Text(theLetter.uppercased())
                .font(.system(size: 60, design: self.fontDesign))
        }
        .frame(height: 68)
    }
}

#Preview {
    LetterBox(theLetter: "A", theState: LetterBoxState.Empty, fontDesign: .serif)
}
