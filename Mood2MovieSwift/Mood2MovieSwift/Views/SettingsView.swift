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
                heroSummary
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

            VStack(alignment: .leading, spacing: 6) {
                Text("CONFIGURE")
                    .font(.caption2.weight(.bold))
                    .tracking(3)
                    .foregroundStyle(Color(hex: "F5A623"))
                Text("Settings")
                    .font(.system(size: 34, weight: .black, design: .rounded))
                Text("Tune the platforms and country used by the recommendation engine.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Divider()
                .overlay(Color(hex: "F5A623").opacity(0.7))
        }
    }

    private var platformSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                SectionHeader(title: "Streaming Platforms")
                Text("Pick the services you actually use so recommendations stay relevant.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 12)], spacing: 12) {
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
            VStack(alignment: .leading, spacing: 12) {
                SectionHeader(title: "Country")
                Picker("Country", selection: $selectedCountry) {
                    ForEach(MoodCatalog.countries) { country in
                        Text(country.name).tag(country.code)
                    }
                }
                .pickerStyle(.menu)

                Text("Country affects availability results and provider matching.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var contentSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                SectionHeader(title: "Content")

                Toggle(isOn: $familySafe) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Family-safe mode")
                        Text("PG-13 and below - always on for Family audience")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
                .toggleStyle(.switch)

                Text("When this is on, the discovery engine leans away from harder-rated titles.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                HStack(spacing: 8) {
                    SummaryPill(text: familySafe ? "Filtered" : "Open catalog")
                    SummaryPill(text: selectedCountry)
                }
            }
        }
    }

    private var apiSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                SectionHeader(title: "Movie Intelligence")
                Text("These values are stored locally on this Mac and used by the recommendation engine.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                VStack(alignment: .leading, spacing: 10) {
                    SecureField("TMDB API Key", text: $tmdbAPIKey)
                        .textFieldStyle(.roundedBorder)
                    SecureField("Anthropic API Key", text: $anthropicAPIKey)
                        .textFieldStyle(.roundedBorder)
                    TextField("Anthropic Model", text: $anthropicModel)
                        .textFieldStyle(.roundedBorder)
                }
            }
        }
    }

    private var cloudSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                SectionHeader(title: "Cloud Sync")
                Text("Supabase powers sign-in and cross-device library sync.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                VStack(alignment: .leading, spacing: 10) {
                    TextField("Supabase URL", text: $supabaseURL)
                        .textFieldStyle(.roundedBorder)
                    SecureField("Supabase Anon Key", text: $supabaseAnonKey)
                        .textFieldStyle(.roundedBorder)
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
            Text("Save & go home")
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

    private var heroSummary: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Tune the engine")
                        .font(.caption2.weight(.bold))
                        .tracking(3)
                        .foregroundStyle(Color(hex: "F5A623"))
                    Text("Set up platforms, country, content filters, and your API keys in one place.")
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .fixedSize(horizontal: false, vertical: true)
                    Text("Changes apply immediately after saving, so the app stays responsive while you refine it.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                HStack(spacing: 12) {
                    SettingsStat(label: "Platforms", value: "\(selectedPlatforms.count)")
                    SettingsStat(label: "Keys", value: "\(configuredKeyCount)")
                    SettingsStat(label: "Safe", value: familySafe ? "On" : "Off")
                }
            }
        }
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

private struct SettingsStat: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .trailing, spacing: 2) {
            Text(value)
                .font(.system(size: 24, weight: .black, design: .rounded))
            Text(label.uppercased())
                .font(.caption2.weight(.bold))
                .tracking(2)
                .foregroundStyle(.secondary)
        }
    }
}

private struct SummaryPill: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                Capsule(style: .continuous)
                    .fill(Color.white.opacity(0.06))
                    .overlay(
                        Capsule(style: .continuous)
                            .stroke(Color.white.opacity(0.09), lineWidth: 1)
                    )
            )
            .foregroundStyle(.secondary)
    }
}

private struct PlatformTile: View {
    let platform: Platform
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: platform.symbolName)
                        .foregroundStyle(isSelected ? Color(hex: "0D0D0F") : Color(hex: "F5A623"))
                    Spacer()
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(isSelected ? Color(hex: "0D0D0F") : Color.secondary)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(platform.name)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(isSelected ? Color(hex: "0D0D0F") : Color.primary)
                    Text("TMDB \(platform.tmdbId)")
                        .font(.caption2)
                        .foregroundStyle(isSelected ? Color(hex: "0D0D0F").opacity(0.75) : Color.secondary)
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, minHeight: 92, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(isSelected ? Color(hex: "F5A623") : Color.white.opacity(0.04))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(isSelected ? Color(hex: "F5A623") : Color.white.opacity(0.08), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}
