import SwiftUI

enum Language: String, CaseIterable, Identifiable, Hashable {
    case english = "English"
    case chinese = "Chinese"
    case tamil = "Tamil"
    case malay = "Malay"

    var id: String { self.rawValue }
}

struct ContentView: View {
    var body: some View {
        NavigationStack {
            HomeView(selectedLanguage: .constant(Language.english))
        }
    }
}




#Preview {
    ContentView()
}
