//
//  OnboardingView.swift
//  IOS_Nirvana
//
//  Created by Avyan Mehra on 25/6/25.
//

import SwiftUI

struct OnboardingView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var language: String
    
    let steps: [LocalizedStep] = [
        LocalizedStep(
            icon: "arrowshape.turn.up.right.fill",
            text: [
                "English": "Connect the correct villager and drag him to the correct tree! You cannot drag through trees, other villagers, or their paths! You can click on the villager to restart the path.",
                "Chinese": "连接正确的村民并拖动他到对应的树！你不能穿过其他树、村民或路径！点击村民可以重新开始路径。",
                "Malay": "Sambungkan penduduk kampung yang betul dan seret dia ke pokok yang betul! Anda tidak boleh melalui pokok lain, penduduk lain, atau laluan mereka! Klik penduduk untuk mula semula.",
                "Tamil": "சரியான கிராமவாசியை இணைத்து அவரை சரியான மரத்திற்கு இழுக்கவும்! மரங்கள், மற்ற கிராமவாசிகள், அல்லது பாதைகள் வழியாக செல்ல முடியாது! பாதையை மீண்டும் தொடங்க அவரை தட்டவும்."
            ]
        ),
        LocalizedStep(
            icon: "sparkles",
            text: [
                "English": "When you successfully bring a villager to their tree, you will receive a historical fact about Redhill!",
                "Chinese": "当你成功地将村民带到他们的树上时，你将获得一个关于红山的历史事实！",
                "Malay": "Apabila anda berjaya membawa penduduk ke pokok mereka, anda akan menerima fakta sejarah tentang Redhill!",
                "Tamil": "நீங்கள் கிராமவாசியை மரத்திடம் வெற்றிகரமாக கொண்டு சென்றால், ரெட்ஹில் பற்றிய வரலாற்றுத் தகவலைப் பெறுவீர்கள்!"
            ]
        ),
        LocalizedStep(
            icon: "paintpalette.fill",
            text: [
                "English": "Remember, you have to match the colours - but don't forget to drag the villager to the tree, not the tree to the villager!",
                "Chinese": "记住，你必须匹配颜色 - 但不要忘了是将村民拖到树，而不是把树拖到村民！",
                "Malay": "Ingat, anda mesti padankan warna - tetapi jangan lupa untuk seret penduduk ke pokok, bukan pokok ke penduduk!",
                "Tamil": "நிறங்களை பொருத்துங்கள் - ஆனால் மரத்தை கிராமவாசியிடம் இழுக்கும் பதிலாக, அவரை மரத்திடம் இழுக்க வேண்டும் என்பதை மறந்துவிடாதீர்கள்!"
            ]
        )
    ]
    
    var body: some View {
        VStack(spacing: 30) {
            Text(localized("Welcome to Redhill!", language: language))
                .font(.largeTitle)
                .bold()
                .multilineTextAlignment(.center)
                .padding(.top, 40)
            
            VStack(alignment: .leading, spacing: 20) {
                ForEach(Array(steps.enumerated()), id: \.element.id) { (index, step) in
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: step.icon)
                            .frame(width: 24, height: 24)
                            .foregroundColor(.blue)
                        VStack(alignment: .leading) {
                            Text("\(index + 1). \(step.localizedText(for: language))")
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }
            .padding(.horizontal, 30)
            
            Spacer()
            
            Text(localized("Good Luck!", language: language))
                .font(.title2)
                .bold()
                .padding(.bottom, 20)
            
            Button(localized("Let's Start!", language: language)) {
                dismiss()
            }
            .font(.title2)
            .foregroundColor(.white)
            .padding()
            .background(Color.blue)
            .cornerRadius(10)
            .padding(.bottom, 40)
        }
        .background(Color(.systemBackground))
    }
}

func localized(_ text: String, language: String) -> String {
    let map: [String: [String: String]] = [
        "Welcome to Redhill!": [
            "Chinese": "欢迎来到红山！",
            "Malay": "Selamat datang ke Redhill!",
            "Tamil": "ரெட்ஹிலுக்கு வரவேற்கிறோம்!"
        ],
        "Good Luck!": [
            "Chinese": "祝你好运！",
            "Malay": "Semoga berjaya!",
            "Tamil": "வாழ்த்துகள்!"
        ],
        "Let's Start!": [
            "Chinese": "开始吧！",
            "Malay": "Mari Mula!",
            "Tamil": "தொடங்கலாம்!"
        ]
    ]
    return map[text]?[language] ?? text
}
