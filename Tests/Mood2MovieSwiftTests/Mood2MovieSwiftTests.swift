import Testing
@testable import Mood2MovieSwift

@Test func moodDraftCompletesForStandardGenre() {
    var draft = MoodSelectionDraft()
    #expect(draft.isComplete == false)

    draft.audience = .solo
    draft.genre = .comedy
    #expect(draft.isComplete == true)

    let resolved = draft.resolved
    #expect(resolved?.audience == .solo)
    #expect(resolved?.genre == .comedy)
    #expect(resolved?.decade == nil)
}

@Test func classicSelectionsNeedADecade() {
    var draft = MoodSelectionDraft(audience: .couple, genre: .classic)
    #expect(draft.isComplete == false)

    draft.decade = .eighties
    #expect(draft.isComplete == true)
    #expect(draft.resolved?.decade == .eighties)
}

@Test func tmdbGenreMappingMatchesSourceProject() {
    #expect(MoodCatalog.genre(for: 878) == .sciFi)
    #expect(MoodCatalog.genre(for: 35) == .comedy)
    #expect(MoodCatalog.genre(for: 99) == .documentary)
}
