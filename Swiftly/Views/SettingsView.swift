import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var authVM: AuthViewModel

    var body: some View {
        // HStack {
        //     Text("Settings")
        //         .font(.title3)
        //         .fontWeight(.semibold)
        //         .fontDesign(.rounded)
        //         .foregroundStyle(.primary)
        //         .fixedSize(horizontal: false, vertical: true)
        //         .clipped()
        // }
        // .padding()

        ScrollView {
            VStack(spacing: 24) {
                // MARK: - Entitlements

                SharedComponents.card {
                    VStack(alignment: .center, spacing: 20) {
                        Text("Unlock Everything")
                            .font(.title3)
                            .fontWeight(.semibold)

                        Text("Biome includes 7 days of Biome PRO for free. Cancel anytime.")
                            .font(.subheadline)
                            .foregroundStyle(.primary.opacity(0.5))
                            .frame(maxWidth: 260, alignment: .center)
                            .multilineTextAlignment(.center)

                        Button(action: {
                            // TODO: Implement unlock everything
                        }) {
                            Text("Redeem 7-day free trial")
                                .font(.headline)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 16)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .foregroundStyle(.background)
                                .background(.primary)
                                .cornerRadius(32)
                        }

                        Text("Then $29.99 per year ($2.50/month)")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(.primary.opacity(0.8))
                            .multilineTextAlignment(.center)
                    }
                    .padding(8)
                }

                // MARK: - Support

                SharedComponents.card {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Support")
                            .font(.subheadline)

                        VStack(spacing: 0) {
                            NavigationLink(destination: Text("Contact Us")) {
                                HStack {
                                    Image(systemName: "message.fill")
                                        .padding(.trailing, 8)
                                    Text("Contact Us")
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                }
                                .padding(.vertical, 16)
                                .font(.headline)
                            }
                            Divider()
                                .padding(.leading, 36)
                            NavigationLink(destination: Text("Leave a Review")) {
                                HStack {
                                    Image(systemName: "star.fill")
                                        .padding(.trailing, 8)
                                    Text("Leave a Review")
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                }
                                .padding(.vertical, 16)
                                .font(.headline)
                            }
                            Divider()
                                .padding(.leading, 36)

                            NavigationLink(destination: Text("Submit Feedback")) {
                                HStack {
                                    Image(systemName: "hand.thumbsup.fill")
                                        .padding(.trailing, 8)
                                    Text("Submit Feedback")
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                }
                                .padding(.vertical, 16)
                                .font(.headline)
                            }
                            Divider()
                                .padding(.leading, 36)

                            NavigationLink(destination: Text("Share Biome")) {
                                HStack {
                                    Image(systemName: "square.and.arrow.up.fill")
                                        .padding(.trailing, 8)
                                    Text("Share Biome")
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                }
                                .padding(.top, 16)
                                .font(.headline)
                            }
                        }
                    }
                    .padding(8)
                }

                // MARK: - Legal

                SharedComponents.card {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Legal")
                            .font(.subheadline)

                        VStack(spacing: 0) {
                            NavigationLink(destination: Text("Privacy Policy")) {
                                HStack {
                                    Image(systemName: "lock.fill")
                                        .padding(.trailing, 8)
                                    Text("Privacy Policy")
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                }
                                .padding(.vertical, 16)
                                .font(.headline)
                            }
                            Divider()
                                .padding(.leading, 36)

                            NavigationLink(destination: Text("Terms of Service")) {
                                HStack {
                                    Image(systemName: "doc.text.fill")
                                        .padding(.trailing, 8)
                                    Text("Terms of Service")
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                }
                                .padding(.top, 16)
                                .font(.headline)
                            }
                        }
                    }
                    .padding(8)
                }

                // MARK: - Account

                SharedComponents.card {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Account")
                            .font(.subheadline)

                        VStack(spacing: 0) {
                            NavigationLink(destination: Text("patrickpc1015@gmail.com")) {
                                HStack {
                                    Image(systemName: "person.fill")
                                        .padding(.trailing, 8)
                                    Text("patrickpc1015@gmail.com")
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                }
                                .padding(.vertical, 16)
                                .font(.headline)
                            }
                            Divider()
                                .padding(.leading, 36)

                            HStack {
                                Image(systemName: "sparkle")
                                    .padding(.trailing, 8)
                                Text("Manage Subscription")
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .padding(.vertical, 16)
                            .font(.headline)
                            .onTapGesture {
                                Task {
                                    await authVM.showManageSubscriptions()
                                }
                            }

                            Divider()
                                .padding(.leading, 36)

                            HStack {
                                Image(systemName: "rectangle.portrait.and.arrow.right.fill")
                                    .padding(.trailing, 8)
                                Text("Sign Out")
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .padding(.top, 16)
                            .font(.headline)
                            .onTapGesture {
                                authVM.signOut()
                            }
                        }
                    }
                    .padding(8)
                }
            }
            .padding()
        }
    }
}

#Preview {
    SettingsView()
}
