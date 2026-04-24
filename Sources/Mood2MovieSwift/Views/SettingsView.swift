import SwiftUI

struct SettingsView: View {
    @Environment(AppStore.self) private var store
    @Binding var path: [AppRoute]

    @State private var selectedPlatforms: Set<String> = []
    @State private var selectedCountry = "US"
    @State private var familySafe = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                header
                platformSection
                countrySection
                contentSection
                saveButton
            }
            .padding(.vertical, 24)
            .padding(.horizontal, 20)
            .frame(maxWidth: 820, alignment: .leading)
        }
        .background(backgroundView)
        .navigationBarBackButtonHidden(true)
        .task {
            selectedPlatforms = Set(store.preferences.platforms)
            selectedCountry = store.preferences.country
            familySafe = store.preferences.familySafe
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
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Streaming Platforms")
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
        .padding(16)
        .background(cardBackground)
    }

    private var countrySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Country")
            Picker("Country", selection: $selectedCountry) {
                ForEach(MoodCatalog.countries) { country in
                    Text(country.name).tag(country.code)
                }
            }
            .pickerStyle(.menu)
        }
        .padding(16)
        .background(cardBackground)
    }

    private var contentSection: some View {
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
        }
        .padding(16)
        .background(cardBackground)
    }

    private var saveButton: some View {
        Button {
            store.setPlatforms(Array(selectedPlatforms).sorted())
            store.setCountry(selectedCountry)
            store.setFamilySafe(familySafe)
            path.removeAll()
        } label: {
            Text("Save & go home")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(PrimaryActionButtonStyle(isEnabled: true))
    }

    private var backgroundView: some View {
        LinearGradient(
            colors: [Color(hex: "09090B"), Color(hex: "111114"), Color(hex: "0D0D10")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 20, style: .continuous)
            .fill(Color.white.opacity(0.045))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
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
