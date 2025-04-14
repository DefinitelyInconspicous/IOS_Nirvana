//
//  StoryView.swift
//  IOS_Nirvana
//
//  Created by Avyan Mehra on 13/4/25.
//

import SwiftUI

struct StoryView: View {
    let language: Language
    @State private var showARView = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(getStoryTitle(for: language))
                    .font(.title)
                    .bold()

                Text(getStory(for: language))
                    .font(.body)

                Spacer().frame(height: 30)

                Button(action: {
                    showARView = true
                }) {
                    HStack {
                        Spacer()
                        Text(getAR(for: language))
                            .font(.title2)
                            .foregroundColor(.primary)
                            .padding()

                        Spacer()

                        Image(systemName: "chevron.right")
                            .foregroundColor(.blue)
                            .padding()
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemGray6))
                    )
                }
                .buttonStyle(.plain)
                .padding(.horizontal)
                .fullScreenCover(isPresented: $showARView) {
                    ARViewScreen()
                }
            }
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
    
    func getAR(for language: Language) -> String {
        switch language {
        case .english:
            return "Explore in AR"
        case .chinese:
            return "在 AR 中探索"
        case .tamil:
            return "AR இல் ஆராயுங்கள்"
        case .malay:
            return "Teroka dalam AR"
        }
    }
    
    func getStoryTitle(for language: Language) -> String {
        switch language {
        case .english:
            return "The Story of Redhill"
        case .chinese:
            return "红山的故事"
        case .tamil:
            return "ரெட்ஹில்லின் கதை"
        case .malay:
            return "Kisah Redhill"
        }
    }
}

#Preview {
    StoryView(language: .english)
}

