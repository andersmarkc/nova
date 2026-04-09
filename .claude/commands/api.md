# /api

Add a new Pulsar API endpoint integration.

## Argument

The endpoint. Example: `/api GET /search`

## Steps

1. Read @docs/PULSAR_API.md — confirm the endpoint spec, request/response shape
2. Show the file plan, wait for confirmation
3. Implement in order:
   a. Response model in `Nova/Models/API/` — Codable struct, snake_case CodingKeys
   b. Request method in `Nova/Services/API/PulsarAPI+{Feature}.swift` — extension on PulsarAPI
   c. Mock response JSON fixture in `NovaTests/Fixtures/`
   d. Test with MockURLProtocol in `NovaTests/Services/`
4. Run `/ci`

## Non-negotiable rules

- All response types are Codable structs with explicit CodingKeys
- Money fields use Decimal, never Float/Double
- Date fields use ISO8601 decoding
- Every endpoint method returns a typed result, never raw Data or JSON
