
//  yansoonApp.swift
//  yansoon
//
//  Created by Sarah on 13/08/1447 AH.
//
import SwiftUI

@main
struct yansoonApp: App {
    var body: some Scene {
        WindowGroup {
            // MainFlowView handles the logic for switching between
            // TimeLimitView and EnergySelectionView
            MainFlowView()
        }
    }
}
