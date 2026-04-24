import SwiftUI

struct SettingsView: View {
    @Environment(AppStore.self) private var store
    @Environment(AppConfigurationStore.self) private var configuration
    @Binding var path: [AppRoute]

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
            .padding(.horizontal, 20)
            .frame(maxWidth: 980, alignment: .leading)
        }
        .background(AppScreenBackground())
        .navigationBarBackButtonHidden(true)
        .task {
            selectedPlatforms = Set(store.preferences.platforms)
            selectedCountry = store.preferences.country
            familySafe = store.preferences.familySafe
            loadConfiguration()
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
                Text("Settings")
                    .font(.system(size: 32, weight: .black, design: .rounded))
                Text("Tune the platforms and country used by the recommendation engine.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
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

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 160), spacing: 12)], spacing: 12) {
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
            HStack(alignment: .top, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Tune the engine")
                        .font(.system(size: 28, weight: .black, design: .rounded))
                    Text("Set up platforms, country, content filters, and your API keys in one place.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 6) {
                    Text("\(selectedPlatforms.count)")
                        .font(.system(size: 30, weight: .black, design: .rounded))
                    Text("platforms selected")
                        .font(.caption2.weight(.semibold))
                        .tracking(2)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

private struct PlatformTile: View {
    let platform: Platform
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: platform.symbolName)
                    .foregroundStyle(isSelected ? Color(hex: "0D0D0F") : Color(hex: "F5A623"))
                VStack(alignment: .leading, spacing: 2) {
                    Text(platform.name)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(isSelected ? Color(hex: "0D0D0F") : Color.primary)
                    Text("TMDB \(platform.tmdbId)")
                        .font(.caption2)
                        .foregroundStyle(isSelected ? Color(hex: "0D0D0F").opacity(0.75) : Color.secondary)
                }
                Spacer()
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(isSelected ? Color(hex: "F5A623") : Color.white.opacity(0.04))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(isSelected ? Color(hex: "F5A623") : Color.white.opacity(0.08), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}
