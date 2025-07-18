//
//  LocalizedStep.swift
//  IOS_Nirvana
//
//  Created by Avyan Mehra on 14/7/25.
//

import Foundation

struct LocalizedStep: Identifiable {
    let id = UUID()
    let icon: String
    let text: [String: String]

    func localizedText(for language: String) -> String {
        return text[language] ?? text["English"] ?? ""
    }
}
