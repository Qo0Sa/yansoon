//
//  ContentView.swift
//  yansoon
//
//  Created by Sarah on 13/08/1447 AH.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text(" Yansoon")
                .font(AppFont.main(size: 32))
            
            Text(" يانسون")
                .font(AppFont.main(size: 32))
        }
    }
}

#Preview {
    ContentView()
}
