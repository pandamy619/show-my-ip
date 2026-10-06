import Testing

func waitUntil(
    _ condition: @escaping @Sendable () async -> Bool,
    sourceLocation: SourceLocation = #_sourceLocation
) async throws {
    for _ in 0..<1000 {
        if await condition() {
            return
        }
        try await Task.sleep(for: .milliseconds(1))
    }
    Issue.record("Condition was not met in time", sourceLocation: sourceLocation)
}
