import SwiftUI

struct AppScreenBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(hex: "050507"),
                    Color(hex: "09090C"),
                    Color(hex: "111118")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            RadialGradient(
                colors: [Color(hex: "F5A623").opacity(0.22), .clear],
                center: .topTrailing,
                startRadius: 24,
                endRadius: 460
            )
            RadialGradient(
                colors: [Color(hex: "6AA8FF").opacity(0.16), .clear],
                center: .bottomLeading,
                startRadius: 32,
                endRadius: 420
            )
        }
        .overlay(alignment: .topTrailing) {
            Circle()
                .fill(Color.white.opacity(0.07))
                .frame(width: 320, height: 320)
                .blur(radius: 90)
                .offset(x: 80, y: -120)
                .allowsHitTesting(false)
        }
        .overlay(alignment: .topLeading) {
            Capsule(style: .continuous)
                .fill(Color(hex: "F5A623").opacity(0.08))
                .frame(width: 220, height: 44)
                .blur(radius: 14)
                .offset(x: -40, y: 80)
                .allowsHitTesting(false)
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
            .padding(15)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.10),
                                Color.white.opacity(0.03),
                                Color.black.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(Color.white.opacity(0.14), lineWidth: 1)
                    )
            )
            .shadow(color: .black.opacity(0.24), radius: 18, x: 0, y: 9)
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
                    .font(.system(size: 17, weight: .black, design: .rounded))
                Text("●")
                    .font(.system(size: 11, weight: .black, design: .rounded))
            }
            .foregroundStyle(Color(hex: "0D0D0F"))
        }
        .frame(width: 42, height: 42)
        .shadow(color: Color(hex: "F5A623").opacity(0.2), radius: 10, x: 0, y: 6)
    }
}

struct CinematicHeroArt: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: "050506"),
                            Color(hex: "120C0A"),
                            Color(hex: "3A2312")
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(Color.white.opacity(0.10), lineWidth: 1)
                )

            RadialGradient(
                colors: [Color(hex: "F5A623").opacity(0.28), .clear],
                center: .trailing,
                startRadius: 12,
                endRadius: 110
            )

            RadialGradient(
                colors: [Color(hex: "7A5132").opacity(0.52), .clear],
                center: .bottomTrailing,
                startRadius: 6,
                endRadius: 140
            )

            VStack(spacing: 0) {
                Spacer(minLength: 0)

                HStack(alignment: .bottom, spacing: 3) {
                    Capsule(style: .continuous)
                        .fill(Color.white.opacity(0.10))
                        .frame(width: 4, height: 18)
                    Capsule(style: .continuous)
                        .fill(Color.white.opacity(0.16))
                        .frame(width: 4, height: 28)
                    Capsule(style: .continuous)
                        .fill(Color.white.opacity(0.08))
                        .frame(width: 4, height: 22)
                    Capsule(style: .continuous)
                        .fill(Color.white.opacity(0.12))
                        .frame(width: 4, height: 34)
                    Capsule(style: .continuous)
                        .fill(Color.white.opacity(0.08))
                        .frame(width: 4, height: 16)
                    Capsule(style: .continuous)
                        .fill(Color.white.opacity(0.14))
                        .frame(width: 4, height: 24)
                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 18)
                .padding(.bottom, 20)
            }

            VStack(spacing: 0) {
                HStack {
                    Spacer(minLength: 0)
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(hex: "FFB24D").opacity(0.92),
                                    Color(hex: "C06A22").opacity(0.72)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 88, height: 20)
                        .overlay(
                            Text("Movie night")
                                .font(.caption2.weight(.bold))
                                .foregroundStyle(Color.black.opacity(0.82))
                        )
                        .padding(.trailing, 14)
                        .padding(.top, 14)
                }
                Spacer(minLength: 0)
            }
        }
        .shadow(color: Color(hex: "F5A623").opacity(0.10), radius: 18, x: 0, y: 8)
    }
}

struct SectionHeader: View {
    let title: String

    var body: some View {
        Text(title.uppercased())
            .font(.caption2.weight(.bold))
            .tracking(2.4)
            .foregroundStyle(.secondary)
    }
}

struct ScreenHeader: View {
    let eyebrow: String
    let title: String
    let subtitle: String
    var badge: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(eyebrow.uppercased())
                        .font(.caption2.weight(.bold))
                        .tracking(3)
                        .foregroundStyle(Color(hex: "F5A623"))
                    Text(title)
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundStyle(Color.white)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(subtitle)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 12)

                if let badge {
                    Text(badge)
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(
                            Capsule(style: .continuous)
                                .fill(Color.white.opacity(0.08))
                                .overlay(
                                    Capsule(style: .continuous)
                                        .stroke(Color.white.opacity(0.12), lineWidth: 1)
                                )
                        )
                        .foregroundStyle(.secondary)
                }
            }

            Divider()
                .overlay(Color(hex: "F5A623").opacity(0.7))
        }
    }
}

struct EmptyStateView: View {
    let message: String

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "FFB84D"), Color(hex: "F5A623")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    Image(systemName: "sparkles")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(Color(hex: "0D0D0F"))
                }
                .frame(width: 42, height: 42)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Nothing to show yet")
                        .font(.headline.weight(.semibold))
                    Text("The app will fill in as you search, save, and sync movies.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }

            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            VStack(alignment: .leading, spacing: 10) {
                Text("Quick start")
                    .font(.caption2.weight(.bold))
                    .tracking(2.5)
                    .foregroundStyle(Color(hex: "F5A623"))
                HStack(spacing: 8) {
                    SummaryPill(text: "Search a title")
                    SummaryPill(text: "Pick a mood")
                    SummaryPill(text: "Save it")
                }
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(Color.white.opacity(0.10), lineWidth: 1)
                )
        )
    }
}

struct LoadingStateView: View {
    let text: String

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color(hex: "F5A623").opacity(0.12))
                    .frame(width: 42, height: 42)
                ProgressView()
                    .tint(Color(hex: "F5A623"))
                    .controlSize(.small)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(text)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.primary)
                Text("This usually takes only a few moments.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(Color.white.opacity(0.10), lineWidth: 1)
                )
        )
    }
}

struct SummaryPill: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                Capsule(style: .continuous)
                    .fill(Color.white.opacity(0.07))
                    .overlay(
                        Capsule(style: .continuous)
                            .stroke(Color.white.opacity(0.10), lineWidth: 1)
                    )
            )
            .foregroundStyle(.secondary)
    }
}

struct LaunchSplashView: View {
    @State private var animate = false

    var body: some View {
        ZStack {
            AppScreenBackground()

            VStack(spacing: 0) {
                Spacer(minLength: 0)

                VStack(spacing: 18) {
                    BrandMark()
                        .scaleEffect(animate ? 1 : 0.84)
                        .opacity(animate ? 1 : 0)

                    VStack(spacing: 8) {
                        Text("Mood2Movie")
                            .font(.system(size: 30, weight: .black, design: .rounded))
                            .foregroundStyle(.white)
                        Text("Pick a movie by how you feel")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }

                    VStack(spacing: 10) {
                        HStack(spacing: 8) {
                            SummaryPill(text: "Mood-driven")
                            SummaryPill(text: "iPhone-first")
                        }

                        HStack(spacing: 6) {
                            RoundedRectangle(cornerRadius: 999, style: .continuous)
                                .fill(Color(hex: "F5A623"))
                                .frame(width: 48, height: 4)
                            RoundedRectangle(cornerRadius: 999, style: .continuous)
                                .fill(Color.white.opacity(0.10))
                                .frame(width: 22, height: 4)
                            RoundedRectangle(cornerRadius: 999, style: .continuous)
                                .fill(Color.white.opacity(0.10))
                                .frame(width: 22, height: 4)
                        }
                    }
                }
                .padding(28)
                .frame(maxWidth: 340)
                .background(
                    RoundedRectangle(cornerRadius: 34, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 34, style: .continuous)
                                .stroke(Color.white.opacity(0.12), lineWidth: 1)
                        )
                )
                .shadow(color: .black.opacity(0.32), radius: 26, x: 0, y: 16)
                .padding(.horizontal, 28)
                .scaleEffect(animate ? 1 : 0.95)

                Spacer(minLength: 0)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.55, dampingFraction: 0.88)) {
                animate = true
            }
        }
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
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color.white.opacity(0.18), lineWidth: 1)
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

            VStack {
                HStack {
                    Spacer()
                    Circle()
                        .fill(Color.white.opacity(0.22))
                        .frame(width: size == .small ? 7 : 9, height: size == .small ? 7 : 9)
                        .padding(6)
                }
                Spacer()
            }
        }
        .frame(width: dimensions.width, height: dimensions.height)
        .shadow(color: genreColor.opacity(0.18), radius: 10, x: 0, y: 6)
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
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(
                        isEnabled
                        ? LinearGradient(
                            colors: [Color(hex: "FFB84D"), Color(hex: "F5A623")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        : LinearGradient(colors: [Color.white.opacity(0.12)], startPoint: .top, endPoint: .bottom)
                    )
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
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.white.opacity(0.04))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color.white.opacity(0.14), lineWidth: 1)
                    )
            )
            .foregroundStyle(.secondary)
            .opacity(configuration.isPressed ? 0.85 : 1)
    }
}

struct FooterLinkButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.footnote.weight(.semibold))
            .padding(.vertical, 11)
            .padding(.horizontal, 14)
            .background(
                RoundedRectangle(cornerRadius: 15, style: .continuous)
                    .fill(Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 15, style: .continuous)
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
