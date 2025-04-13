//
//  ContentView.swift
//  IOS_Nirvana
//
//  Created by Avyan Mehra on 17/2/25.
//

import SwiftUI

enum Language: String, CaseIterable, Identifiable, Hashable {
    case english = "English"
    case chinese = "中文"
    case tamil = "தமிழ்"
    case malay = "Bahasa Melayu"

    var id: String { self.rawValue }
}

struct ContentView: View {
    var body: some View {
        NavigationStack {
            HomeView()
        }
    }
}

struct HomeView: View {
    @State private var selectedLanguage: Language? = nil

    var body: some View {
        VStack(spacing: 30) {
            Text("Choose a Language")
                .font(.largeTitle)
                .bold()

            ForEach(Language.allCases) { lang in
                NavigationLink(value: lang) {
                    Text(lang.rawValue)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
        }
        .padding()
        .navigationDestination(for: Language.self) { language in
            StoryView(language: language)
        }
    }
}

struct StoryView: View {
    let language: Language
    
    var body: some View {
        ScrollView {
            Text(getStory(for: language))
                .font(.body)
                .padding()
        }
        .navigationTitle(language.rawValue)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    func getStory(for language: Language) -> String {
        switch language {
        case .english:
            return "Once upon a time in Redhill, a boy with great strength saved his village from swordfish attacks. The king, fearing his power, had him killed. A red hill rose where his blood was spilled—hence the name Redhill."
        case .chinese:
            return "很久以前，在红山，有一个拥有巨大力量的男孩，他拯救了村庄免受剑鱼袭击。国王因为害怕他的力量而下令杀死他。他流血的地方出现了一座红色的山丘，因此得名“红山”。"
        case .tamil:
            return "Redhill இல் ஒரு சிறுவன் அற்புதமான சக்தியுடன் இருந்தான். அவன் தனது கிராமத்தை வாள் மீன்களின் தாக்குதலிலிருந்து காப்பாற்றினான். அரசன் அவனது சக்தியை பயந்து அவனை கொலை செய்தான். அவன் இரத்தம் சிந்திய இடத்தில் சிவந்த மலையொன்றை உருவாக்கியது. அதனால் அந்த இடம் 'Redhill' என அழைக்கப்பட்டது."
        case .malay:
            return "Pada zaman dahulu di Redhill, seorang budak lelaki yang kuat menyelamatkan kampungnya daripada serangan ikan todak. Raja takut akan kekuatannya dan memerintahkan dia dibunuh. Di tempat darahnya tumpah, muncul sebuah bukit merah. Itulah asal usul nama Redhill."
        }
    }
}

#Preview {
    ContentView()
}
