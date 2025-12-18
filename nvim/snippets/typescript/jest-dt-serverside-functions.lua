return {
  s(
    "describe-app-function",
    fmt(
      [[
      describe('{}', () => {{
        afterEach(() => {{
          jest.clearAllMocks();
          fetchMock.mockClear();
        }});
        test('Succeeds when {}', async () => {{
          const response: {} = {{
            {}
          }};
          fetchMock.mockResponseOnce(JSON.stringify(response));

          const input: {} = {};

          const sut = await {};

          const expectedOutput = {};

          expect(sut).{}(expectedOutput)
        }})
      }});
    ]],
      {
        i(1, "API function"),
        i(2, "that "),
        i(3, "ReturnType"),
        i(4, "{}"),
        i(5, ""),
        i(6, ""),
        i(7, ""),
        i(8, ""),
        i(9, ""),
      }
    )
  ),
  s(
    "test-app-function",
    fmt(
      [[
      test('Succeeds when {}', async () => {{
        const mockedServerResponse: {} = {};
        const input: {} = {};

        // Function is impure ie. side-effect of using Fetch API
        fetchMock.mockResponse(JSON.stringify(mockedServerResponse));
        fetchMock.mockResponse(async (request: Request) => JSON.stringify(mockedServerResponse));
        const sut = await apiFunction(input);

        const expectedOutput: {} = {};
        expect(sut).{}(expectedOutput);
      }}),
    ]],
      {
        i(1, "given 5 users, returns array of length 5"),
        i(2, "MockResponseType"),
        i(3, "mockResponse}"),
        i(4, "InputType"),
        i(5, "input"),
        i(6, "OutputType"),
        i(7, "output"),
        i(8, "toEqual"),
      }
    )
  ),
}
