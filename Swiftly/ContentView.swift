import SwiftUI

struct ContentView: View {
    @EnvironmentObject var mainVM: MainViewModel
    @EnvironmentObject var authVM: AuthViewModel

    var body: some View {
        ZStack {
            if authVM.authState == .unauthenticated {
                AuthView()
            } else {
                BottomNavigationView()
            }
        }
        .onAppear {
            setupInitialState()
        }
        .alert(item: $authVM.error) { error in
            Alert(
                title: Text("Error"),
                message: Text(error.localizedDescription),
                dismissButton: .default(Text("OK")) {
                    authVM.error = nil
                }
            )
        }
    }

    private func setupInitialState() {
        if authVM.authState == .authenticated {
            mainVM.currentPage = .home
        } else {
            mainVM.currentPage = .onboarding
        }
    }
}

enum Page: String {
    case splash = "Splash"
    case auth = "Auth"
    case onboarding = "Onboarding"
    case home = "Home"
    case settings = "Settings"
}

#Preview {
    ContentView()
}
