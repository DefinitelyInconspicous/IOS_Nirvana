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
        VStack(spacing: 20) {
            Spacer(minLength: 30)

            VStack(spacing: 8) {
                Text("Choose a Language")
                    .font(.largeTitle)
                    .bold()
                    .multilineTextAlignment(.center)

                Text("Discover the legend of Redhill in your language")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()

            ForEach(Language.allCases) { lang in
                NavigationLink(value: lang) {
                    HStack {
                        Spacer()
                        Text(lang.rawValue)
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
            }

            Spacer()
        }
        .padding(.vertical)
        .navigationDestination(for: Language.self) { language in
            StoryView(language: language)
        }
    }
}



#Preview {
    ContentView()
}
