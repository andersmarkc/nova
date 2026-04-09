import Testing

extension Tag {
    /// Tests that use MockURLProtocol must run serially because the
    /// static requestHandler is process-wide shared state.
    @Tag static var mockAPI: Self

    /// Integration tests that hit real Pulsar API.
    @Tag static var integration: Self
}
