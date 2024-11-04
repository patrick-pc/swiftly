import FirebaseCore
import RevenueCat
import SuperwallKit
import SwiftUI

@main
struct SwiftlyApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var mainViewModel = MainViewModel()

    @State private var showSplash = true
    @State var selectedTheme: Theme = .secondaryTheme

    var body: some Scene {
        WindowGroup {
            ZStack {
                ContentView()
                    .environmentObject(authViewModel)
                    .environmentObject(mainViewModel)
                    // .environment(\.theme, selectedTheme)
                    .fontDesign(.rounded) // Apply rounded font to the entire app

                if showSplash {
                    SplashView()
                        .transition(.opacity)
                        .zIndex(1)
                }
            }
            .onAppear {
                setup() // Safe to access @StateObject here
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation {
                        showSplash = false
                    }
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                mainViewModel.refreshCustomerInfo()
            }
        }
    }
}

private extension SwiftlyApp {
    func setup() {
        let userId = UserDefaults.standard.string(forKey: "userId") ?? Constants.userId

        // MARK: Step 1 - Create your Purchase Controller

        /// Create an `RCPurchaseController()` wherever Superwall and RevenueCat are being initialized.
        let purchaseController = RCPurchaseController()

        // MARK: Step 2 - Configure Superwall

        /// Always configure Superwall first. Pass in the `purchaseController` you just created.
        Superwall.configure(
            apiKey: "pk_65d8a586a6f84a166634bea9b2b3a0b8b05c51745ab9fd64",
            purchaseController: purchaseController
        )
        Superwall.shared.identify(userId: userId)

        // MARK: Step 3 – Configure RevenueCat

        /// Always configure RevenueCat after Superwall
        Purchases.configure(withAPIKey: "appl_jWmCnQpSCjzWVUJfKHsBHDNRotb", appUserID: userId)

        // MARK: Step 4 – Sync Subscription Status

        /// Keep Superwall's subscription status up-to-date with RevenueCat's.
        purchaseController.syncSubscriptionStatus()

        // MARK: Step 5 – Set Delegate

        /// Set the delegate to receive updates on subscription status.
        Purchases.shared.delegate = mainViewModel

        // Mixpanel.initialize(token: "", trackAutomaticEvents: false)
        // Mixpanel.mainInstance().track(event: "App Start")
        // Mixpanel.mainInstance().identify(distinctId: userId)
    }
}

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(
        _: UIApplication,
        didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()

        return true
    }
}
