import Foundation

private final class BundleToken {}

enum FixtureLoader {
    static func load(_ filename: String) throws -> Data {
        let bundle = Bundle(for: BundleToken.self)
        guard let url = bundle.url(forResource: filename, withExtension: "json") else {
            throw FixtureError.fileNotFound(filename)
        }
        return try Data(contentsOf: url)
    }

    enum FixtureError: Error {
        case fileNotFound(String)
    }
}
