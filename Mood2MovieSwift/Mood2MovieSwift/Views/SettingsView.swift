import SwiftUI

struct SettingsView: View {
    @Environment(AppStore.self) private var store
    @Environment(AppConfigurationStore.self) private var configuration
    @Binding var path: [AppRoute]

    @State private var didAppear = false
    @State private var selectedPlatforms: Set<String> = []
    @State private var selectedCountry = "US"
    @State private var familySafe = false
    @State private var tmdbAPIKey = ""
    @State private var anthropicAPIKey = ""
    @State private var anthropicModel = "claude-3-5-haiku-latest"
    @State private var supabaseURL = ""
    @State private var supabaseAnonKey = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                header
                platformSection
                countrySection
                contentSection
                apiSection
                cloudSection
                saveButton
            }
            .padding(.vertical, 24)
            .padding(.horizontal, 16)
            .frame(maxWidth: 400, alignment: .leading)
            .opacity(didAppear ? 1 : 0)
            .offset(y: didAppear ? 0 : 12)
        }
        .background(AppScreenBackground())
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .task {
            selectedPlatforms = Set(store.preferences.platforms)
            selectedCountry = store.preferences.country
            familySafe = store.preferences.familySafe
            loadConfiguration()
        }
        .onAppear {
            withAnimation(.spring(response: 0.55, dampingFraction: 0.86)) {
                didAppear = true
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button {
                if !path.isEmpty { path.removeLast() }
            } label: {
                Label("Back", systemImage: "chevron.left")
            }
            .buttonStyle(PlainBackButtonStyle())

            ScreenHeader(
                eyebrow: "Configure",
                title: "Settings",
                subtitle: "Tune the platforms and country used by the recommendation engine.",
                badge: "\(configuredKeyCount) keys"
            )
        }
    }

    private var platformSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        SectionHeader(title: "Streaming Platforms")
                        Text("Pick the services you actually use so recommendations stay relevant.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    SummaryPill(text: "\(selectedPlatforms.count) selected")
                }

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 140), spacing: 12)], spacing: 12) {
                    ForEach(MoodCatalog.platforms) { platform in
                        PlatformTile(platform: platform, isSelected: selectedPlatforms.contains(platform.key)) {
                            if selectedPlatforms.contains(platform.key) {
                                selectedPlatforms.remove(platform.key)
                            } else {
                                selectedPlatforms.insert(platform.key)
                            }
                        }
                    }
                }
            }
        }
    }

    private var countrySection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        SectionHeader(title: "Country")
                        Text("Country affects availability results and provider matching.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    SummaryPill(text: selectedCountry)
                }

                Picker("Country", selection: $selectedCountry) {
                    ForEach(MoodCatalog.countries) { country in
                        Text(country.name).tag(country.code)
                    }
                }
                .pickerStyle(.menu)
            }
        }
    }

    private var contentSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        SectionHeader(title: "Content")
                        Text("Keep the vibe family-safe or open the catalog up.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    SummaryPill(text: familySafe ? "Filtered" : "Open")
                }

                Toggle(isOn: $familySafe) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Family-safe mode")
                        Text("PG-13 and below - always on for Family audience")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
                .toggleStyle(.switch)

                HStack(spacing: 8) {
                    SummaryPill(text: familySafe ? "Filtered catalog" : "Open catalog")
                    SummaryPill(text: selectedCountry)
                }
            }
        }
    }

    private var apiSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                VStack(alignment: .leading, spacing: 4) {
                    SectionHeader(title: "Movie Intelligence")
                    Text("These values are stored locally on this Mac and used by the recommendation engine.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                VStack(alignment: .leading, spacing: 10) {
                    SettingsInputField(title: "TMDB API Key", text: $tmdbAPIKey, secure: true)
                    SettingsInputField(title: "Anthropic API Key", text: $anthropicAPIKey, secure: true)
                    SettingsInputField(title: "Anthropic Model", text: $anthropicModel, secure: false)
                }
            }
        }
    }

    private var cloudSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                VStack(alignment: .leading, spacing: 4) {
                    SectionHeader(title: "Cloud Sync")
                    Text("Supabase powers sign-in and cross-device library sync.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                VStack(alignment: .leading, spacing: 10) {
                    SettingsInputField(title: "Supabase URL", text: $supabaseURL, secure: false)
                    SettingsInputField(title: "Supabase Anon Key", text: $supabaseAnonKey, secure: true)
                }

                HStack {
                    Button("Reset to environment defaults") {
                        configuration.resetToEnvironmentDefaults()
                        loadConfiguration()
                    }
                    .buttonStyle(SecondaryActionButtonStyle())
                    Spacer()
                }
            }
        }
    }

    private var saveButton: some View {
        Button {
            store.setPlatforms(Array(selectedPlatforms).sorted())
            store.setCountry(selectedCountry)
            store.setFamilySafe(familySafe)
            configuration.values = AppConfigurationValues(
                tmdbAPIKey: tmdbAPIKey.trimmingCharacters(in: .whitespacesAndNewlines),
                anthropicAPIKey: anthropicAPIKey.trimmingCharacters(in: .whitespacesAndNewlines),
                anthropicModel: anthropicModel.trimmingCharacters(in: .whitespacesAndNewlines),
                supabaseURL: supabaseURL.trimmingCharacters(in: .whitespacesAndNewlines),
                supabaseAnonKey: supabaseAnonKey.trimmingCharacters(in: .whitespacesAndNewlines)
            )
            path.removeAll()
        } label: {
            Text("Save preferences")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(PrimaryActionButtonStyle(isEnabled: true))
    }

    private func loadConfiguration() {
        tmdbAPIKey = configuration.values.tmdbAPIKey
        anthropicAPIKey = configuration.values.anthropicAPIKey
        anthropicModel = configuration.values.anthropicModel
        supabaseURL = configuration.values.supabaseURL
        supabaseAnonKey = configuration.values.supabaseAnonKey
    }

    private var configuredKeyCount: Int {
        [
            tmdbAPIKey,
            anthropicAPIKey,
            supabaseURL,
            supabaseAnonKey
        ].filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }.count
    }
}

private struct SettingsInputField: View {
    let title: String
    @Binding var text: String
    let secure: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            HStack(spacing: 10) {
                Image(systemName: secure ? "lock.fill" : "rectangle.and.pencil.and.ellipsis")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .frame(width: 18)

                Group {
                    if secure {
                        SecureField(title, text: $text)
                    } else {
                        TextField(title, text: $text)
                    }
                }
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .foregroundStyle(.primary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.white.opacity(0.06))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color.white.opacity(0.10), lineWidth: 1)
                    )
            )
        }
    }
}

private struct PlatformTile: View {
    let platform: Platform
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: platform.symbolName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(isSelected ? Color(hex: "0D0D0F") : Color(hex: "F5A623"))
                    Spacer()
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(isSelected ? Color(hex: "0D0D0F") : Color.secondary)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(platform.name)
                        .font(.callout.weight(.semibold))
                        .foregroundStyle(isSelected ? Color(hex: "0D0D0F") : Color.primary)
                }
            }
            .padding(10)
            .frame(maxWidth: .infinity, minHeight: 72, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(
                        isSelected
                        ? LinearGradient(
                            colors: [Color(hex: "FFB84D"), Color(hex: "F5A623")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        : LinearGradient(
                            colors: [Color.white.opacity(0.06), Color.white.opacity(0.03)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(isSelected ? Color(hex: "F5A623").opacity(0.85) : Color.white.opacity(0.10), lineWidth: 0.8)
                    )
                    .overlay(
                        LinearGradient(
                            colors: [Color.white.opacity(0.16), Color.clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    )
            )
        }
        .buttonStyle(.plain)
    }
}
