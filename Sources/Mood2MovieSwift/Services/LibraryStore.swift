import Foundation

public final class LibraryStore {
    private let fileURL: URL
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    public init(fileManager: FileManager = .default) {
        let baseURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? fileManager.temporaryDirectory
        let directory = baseURL.appendingPathComponent("Mood2MovieSwift", isDirectory: true)
        try? fileManager.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
        self.fileURL = directory.appendingPathComponent("library.json")

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        self.encoder = encoder

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        self.decoder = decoder
    }

    public func load() -> [UserMovie] {
        guard let data = try? Data(contentsOf: fileURL),
              let movies = try? decoder.decode([UserMovie].self, from: data) else {
            return []
        }
        return movies
    }

    public func save(_ movies: [UserMovie]) {
        guard let data = try? encoder.encode(movies) else { return }
        try? data.write(to: fileURL, options: [.atomic])
    }
}
