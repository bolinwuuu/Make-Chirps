//
//  SpeechBubble.swift
//  StoryboardChirp
//
//  Created by Kurt Beyer on 3/18/24.
//

import SwiftUI

struct SpeechBubble: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 20)
            .frame(width: 500, height: 80)
            .foregroundColor(.purple)
            .opacity(0.8)
        
    }
}

#Preview {
    SpeechBubble()
}
