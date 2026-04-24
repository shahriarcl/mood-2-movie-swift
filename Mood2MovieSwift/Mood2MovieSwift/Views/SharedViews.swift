import SwiftUI

struct AppScreenBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(hex: "060608"),
                    Color(hex: "0B0B0E"),
                    Color(hex: "121219")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            RadialGradient(
                colors: [Color(hex: "F5A623").opacity(0.18), .clear],
                center: .topTrailing,
                startRadius: 24,
                endRadius: 420
            )

            RadialGradient(
                colors: [Color(hex: "6AA8FF").opacity(0.12), .clear],
                center: .bottomLeading,
                startRadius: 32,
                endRadius: 380
            )

            Circle()
                .fill(Color.white.opacity(0.06))
                .frame(width: 420, height: 420)
                .blur(radius: 120)
                .offset(x: 320, y: -280)
        }
        .ignoresSafeArea()
    }
}

struct GlassCard<Content: View>: View {
    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.white.opacity(0.06))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(Color.white.opacity(0.11), lineWidth: 1)
                    )
            )
            .shadow(color: .black.opacity(0.28), radius: 24, x: 0, y: 12)
    }
}

struct BrandMark: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "F5A623"), Color(hex: "FF7A59")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            VStack(spacing: 0) {
                Text("M2")
                    .font(.system(size: 18, weight: .black, design: .rounded))
                Text("M")
                    .font(.system(size: 18, weight: .black, design: .rounded))
            }
            .foregroundStyle(Color(hex: "0D0D0F"))
        }
        .frame(width: 42, height: 42)
        .shadow(color: Color(hex: "F5A623").opacity(0.2), radius: 10, x: 0, y: 6)
    }
}

struct SectionHeader: View {
    let title: String

    var body: some View {
        Text(title.uppercased())
            .font(.caption2.weight(.semibold))
            .tracking(2.2)
            .foregroundStyle(.secondary)
    }
}

struct EmptyStateView: View {
    let message: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Image(systemName: "sparkles")
                    .foregroundStyle(Color(hex: "F5A623"))
                Text("Nothing to show yet")
                    .font(.headline.weight(.semibold))
            }
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white.opacity(0.045))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
        )
    }
}

struct LoadingStateView: View {
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            ProgressView()
                .controlSize(.small)
            Text(text)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white.opacity(0.045))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
        )
    }
}

struct AvailabilityPill: View {
    let availability: Availability

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(availability.type == .subscription ? Color(hex: "F5A623") : Color.white.opacity(0.35))
                .frame(width: 6, height: 6)
            Text("\(availability.type.label) • \(availability.platformName)")
                .lineLimit(1)
        }
        .font(.caption2.weight(.semibold))
        .foregroundStyle(availability.type == .subscription ? Color(hex: "F5A623") : Color.secondary)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(
            Capsule(style: .continuous)
                .fill(Color.white.opacity(0.06))
                .overlay(
                    Capsule(style: .continuous)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
        )
    }
}

struct PosterBadge: View {
    enum Size { case small, large }

    let genre: MoodGenre
    let title: String
    let year: Int
    let size: Size

    var body: some View {
        let dimensions = size == .small ? CGSize(width: 44, height: 64) : CGSize(width: 76, height: 108)

        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [genreColor.opacity(0.95), genreColor.opacity(0.55)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(size == .small ? .caption2.weight(.semibold) : .caption.weight(.semibold))
                    .foregroundStyle(Color(hex: "0D0D0F"))
                    .lineLimit(2)
                Text("\(year)")
                    .font(.caption2)
                    .foregroundStyle(Color(hex: "0D0D0F").opacity(0.75))
            }
            .padding(8)
        }
        .frame(width: dimensions.width, height: dimensions.height)
    }

    private var genreColor: Color {
        switch genre {
        case .sciFi: Color(hex: "6AA8FF")
        case .romance: Color(hex: "FF8EC7")
        case .comedy: Color(hex: "F7C84B")
        case .action: Color(hex: "FF6A4D")
        case .mystery: Color(hex: "9B8CFF")
        case .horror: Color(hex: "C34A4A")
        case .fantasy: Color(hex: "7CD4B4")
        case .documentary: Color(hex: "8AA0B8")
        case .classic: Color(hex: "D6B36A")
        }
    }
}

struct MoodSelectorView: View {
    @Binding var draft: MoodSelectionDraft

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            choiceGroup(
                title: "Who's watching?",
                values: MoodAudience.allCases,
                selection: draft.audience,
                label: { $0.label }
            ) { draft.audience = $0 }

            choiceGroup(
                title: "What's the vibe?",
                values: MoodVibe.allCases,
                selection: draft.vibe,
                label: { $0.label }
            ) { draft.vibe = $0 }

            choiceGroup(
                title: "Genre spice?",
                values: MoodGenre.allCases,
                selection: draft.genre,
                label: { $0.label }
            ) { draft.genre = $0 }

            if draft.genre == .classic {
                choiceGroup(
                    title: "Classic decade",
                    values: MoodDecade.allCases,
                    selection: draft.decade,
                    label: { $0.label }
                ) { draft.decade = $0 }
            }
        }
    }

    private func choiceGroup<Value: Hashable>(
        title: String,
        values: [Value],
        selection: Value?,
        label: @escaping (Value) -> String,
        onSelect: @escaping (Value) -> Void
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader(title: title)
            FlowLayout(spacing: 8) {
                ForEach(Array(values.enumerated()), id: \.offset) { _, value in
                    let selected = selection == value
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                            onSelect(value)
                        }
                    } label: {
                        Text(label(value))
                            .font(.footnote.weight(.semibold))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                Capsule(style: .continuous)
                                    .fill(selected ? Color(hex: "F5A623") : Color.white.opacity(0.06))
                            )
                            .foregroundStyle(selected ? Color(hex: "0D0D0F") : Color.primary)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) -> CGSize {
        let maxWidth = proposal.width ?? 600
        var x: CGFloat = 0
        var y: CGFloat = 0
        var lineHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth, x > 0 {
                x = 0
                y += lineHeight + spacing
                lineHeight = 0
            }
            x += size.width + spacing
            lineHeight = max(lineHeight, size.height)
        }

        return CGSize(width: maxWidth, height: y + lineHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) {
        var x = bounds.minX
        var y = bounds.minY
        var lineHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX, x > bounds.minX {
                x = bounds.minX
                y += lineHeight + spacing
                lineHeight = 0
            }
            subview.place(
                at: CGPoint(x: x, y: y),
                proposal: ProposedViewSize(size)
            )
            x += size.width + spacing
            lineHeight = max(lineHeight, size.height)
        }
    }
}

struct PrimaryActionButtonStyle: ButtonStyle {
    let isEnabled: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.weight(.semibold))
            .padding(.vertical, 14)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(isEnabled ? Color(hex: "F5A623") : Color.white.opacity(0.12))
            )
            .foregroundStyle(isEnabled ? Color(hex: "0D0D0F") : Color.secondary)
            .opacity(configuration.isPressed ? 0.85 : 1)
    }
}

struct SecondaryActionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.weight(.semibold))
            .padding(.vertical, 14)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color.white.opacity(0.14), lineWidth: 1)
            )
            .foregroundStyle(.secondary)
            .opacity(configuration.isPressed ? 0.85 : 1)
    }
}

struct FooterLinkButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.footnote.weight(.semibold))
            .padding(.vertical, 12)
            .padding(.horizontal, 14)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.white.opacity(0.06))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(Color.white.opacity(0.10), lineWidth: 1)
                    )
            )
            .foregroundStyle(.secondary)
            .opacity(configuration.isPressed ? 0.85 : 1)
    }
}

struct PlainBackButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.footnote.weight(.semibold))
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(Color.white.opacity(0.14), lineWidth: 1)
            )
            .foregroundStyle(.secondary)
            .opacity(configuration.isPressed ? 0.8 : 1)
    }
}

struct InlineActionButtonStyle: ButtonStyle {
    let isActive: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.caption.weight(.semibold))
            .padding(.vertical, 8)
            .padding(.horizontal, 10)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(isActive ? Color(hex: "F5A623").opacity(0.95) : Color.white.opacity(0.05))
            )
            .foregroundStyle(isActive ? Color(hex: "0D0D0F") : Color.secondary)
            .opacity(configuration.isPressed ? 0.85 : 1)
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 245, 166, 35)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
