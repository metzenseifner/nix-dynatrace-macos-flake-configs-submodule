return {

  s("jest.automock", fmt([[
    // add to jest config to run jest.mock on all imports in test module.
    // not to be confused with https://jestjs.io/docs/es6-class-mocks#automatic-mock (ambiguous name)
    module.exports = {
      automock: true,
    }
  ]], {}, { delimiters = "[]" })),
  s("jest.mock-explanation", fmt([[
    It replaces the ES6 class with a mock constructor, and replaces all of its methods with mock functions that always return undefined.
    The following is performed on the module for exported values:
    - Function will be transformed to spy function doing noop (like, the jest.fn())
    - Array will be transformed to empty array.
    - ES6 Class will be transformed like function
    - Number, Object, String won't be affected.
  ]], {}, {})),
  s("mock", fmt([[
    const mock[symbolF] = [symbol] as jest.MockedFunction<typeof [symbol]>;
  ]], {
      symbol = i(1, "symbol"),
      symbolF = f(
      -- TODO add smarts to handle classes/objects differently (when .
      -- notation, extract only symbol tail for a for assigned constant)
      -- make init char upper case
        function(v) return v[1][1] end, { 1 })
    }, { delimiters = "[]", repeat_duplicates = true },
    {})),

  s("jest.mock", fmt([[
    jest.mock<typeof import ('[modulePath]')>('[modulePath]');
  ]], { modulePath = i(1, "modulePathOrFilePath") }, { delimiters = "[]", repeat_duplicates = true })),

  s("jest.mock-with-comments", fmt([=[
    // mock must always be at the top of the module (not within describe blocks). Use doMock if scoping within describe block
    // because jest.mock calls cannot be hoisted to the top of the module if you enabled ECMAScript modules support and Jest needs to auto hoist jest.mock calls to the top of the module: https://jestjs.io/docs/manual-mocks#using-with-es-module-imports
    // therefore you have to put them there yourself.
    jest.mock<typeof import ('[modulePath]')>('[modulePath]'); // watch for calls on this path; exported classes are mock constructors
    const mock[symbolF] = [symbol] as jest.MockedFunction<<typeof [symbol]>>;  // mock a specific exported function
    const mock[symbolF] = replaceMeWithClassInstance.mock.instances[[0]].[symbol]; // access auto-mocked instance method
  ]=],
    {
      modulePath = i(1, "modulePathOrFilePath"),
      symbol = i(2, "symbol-that-must-be-watched-by-jest.mock"),
      symbolF = f(
        function(v) return v[1][1] end, { 2 })
    }, { delimiters = "[]", repeat_duplicates = true }
  )),
  s("it-template-async", fmt([=[
      it('[description]', async () => {
        throw new Error(`Not yet implemented`);
      });
  ]=], { description = i(1, "description") }, { delimiters = "[]" })),
  s("it-not-yet-implemented", fmt([=[
      it.skip('[description]', async () => {
        throw new Error(`Not yet implemented`);
      });
  ]=], { description = i(1, "description") }, { delimiters = "[]" })),

  s({ trig = [[jest.fn-typed]], regTrig = false, name = "jest-fn" }, fmt([=[
    // note you can also put content of mockImplementation as arg to fn
    jest.fn<ReturnType<typeof [T]>, Parameters<typeof [T]>>().mockName("[name]").mockImplementation(([args]) => result);
  ]=], { T = i(1, "funcref"), args = i(3, "args"), name = i(2, "name used in logs on failure") },
    { repeat_duplicates = true, delimiters = "[]" })),
  s("jest.fn-typed-auto", fmt([[
  // watch module path
  jest.mock('./ConnectionOverviewContent');
  // assign real function to a mock-prefixed version typed as a jest.MockedFunction<typeof real function>
  const mockConnectionOverviewContent = ConnectionOverviewContent as jest.MockedFunction<
    typeof ConnectionOverviewContent
  >;
  ]], {}, { delimiters = "[]" })),

  s("describe", fmt([[
    describe('[what]', () => {[]})
  ]], { what = d(1, function(args, parent)
    local insertSnippetNodeFromSelectionElseInsertNode = function(args, parent)
      if (#parent.snippet.env.LS_SELECT_RAW > 0) then
        return sn(nil, t(parent.snippet.env.LS_SELECT_RAW))
      else
        return sn(nil, i(1, "what"))
      end
    end
    insertSnippetNodeFromSelectionElseInsertNode(args, parent)
  end), i(2) }, { delimiters = "[]" })),

  s("it", fmt([[
    it("should [what]", async () => {[]})
  ]], {what = i(1), i(2)}, {delimiters="[]"})),
  s("describe-block-with-test", fmt([[
    describe('[suite_description]', () => {
      // For this suite, "sut" means "subject under test"
      it('[test_behavior]', () => {
        const input = [input]
        const expectedOutput = [expectedOutput]

        const sut = [sut]

        [condition]
      })
    })
  ]],
    {
      suite_description = i(1, "suitetopic"),
      test_behavior = i(2, "behavior"),
      input = i(3, "input"),
      expectedOutput = i(4, "expectedOutput"),
      sut = i(5, "subject_under_test"),
      condition = i(6, "condition")
    }, { delimiters = '[]' }
  )),
  s("jest-it-test", fmt([[
    it('[test_description]', async () => {
      const sut = [sut];
    })
  ]], { test_description = i(1, "Description"), sut = i(2, "subject_under_test") }, { delimiters = "[]" })),
  s("jest-mock-function-override-help", fmt([[
    // check mock member for utils: calls count, instances count, last call
    const f = jest.fn((...args) => args))

    // Alternative syntax
    const g = jest.fn()
    g.mockReturnValue([rvalue])
    g.mockResponseOnce([rvalue])
  ]], { rvalue = i(1, "returnvalue") }, { delimiters = "[]", repeat_duplicates = true })),
  s("jest-mock-function-override", fmt([[
    // check mock member for utils: calls count, instances count, last call
    const f = jest.fn((...args) => args))
  ]], {}, { delimiters = "[]" })),
  s("jest-mock-logger-spy", fmt([[
    jest.mocked(ConsoleLogger).mockImplementation(() => {
      return {
        debug: jest.fn(),
        error: jest.fn(),
        info: jest.fn(),
        warn: jest.fn(),
      };
    });
    const logInfoSpy = jest.spyOn(ConsoleLogger.prototype, 'info');
  ]], {}, { delimiters = "[]" })),

  s("jest.fn-typed", fmt([[
    const [name]Mock = [name] as jest.MockedFunction<typeof [name]>;
  ]], { name = i(1, "name") }, { repeat_duplicates = true, delimiters = "[]" })),

  s("jest.mock-request", fmt([[
    const mockGuardiansRequest = RequestMock()
      .onRequestTo(buildSomeUrl(`settings/objects?schemaIds=${encodeURIComponent(config.schemaId)}`))
      .respond(mockedGuardians)
      .onRequestTo(buildQueryUrl(validationsQueryRegex))
      .respond(mockedValidations);
  ]], {}, { delimiters = "<>" })),
  s("jest-test-throw", fmt([[
    //await expect(sut).rejects.toThrow("error msg");
    //expect(sut).toThrow("error msg")
  ]], {}, { delimiters = "<>" })),
  s("jest-test-pure-function", fmt([=[
    test('0 Case', async () => {
      const input: <[INPUT_TYPE]> = [INPUT];

      const sut = await [FUNCTION](input);

      expect(sut).toEqual([EXPECTED_OUTPUT]);
    });
  ]=], {
    INPUT_TYPE = i(1, "Type"),
    INPUT = i(2, "Input"),
    FUNCTION = i(3, "Function"),
    EXPECTED_OUTPUT = i(4, "ExpectedValue")
  }, { delimiters = "[]" })),

  s("jest-test-api-function", fmt([[
    test('[description]', async () => {
      const simulatedTargetResponse: [TargetResponseType] = [sampleResponseData];

      // TODO: DELETEME Handle effect of contacting outside world within Dynatrace runtime
      fetchMock.mockResponseOnce(JSON.stringify(simulatedTargetResponse));

      const input: [InputType] = [inputData];

      const sut = await apiFunction(input);

      const expectedOutput: [OutputType] = [outputData];

      expect(sut).toEqual(expectedOutput)
    })
  ]], {
    description = i(1, "Succeeds when..."),
    TargetResponseType = i(2, "TargetResponseType"),
    sampleResponseData = i(3, "sampleResponseData"),
    InputType = i(4, "InputType"),
    inputData = i(5, "inputData"),
    OutputType = i(6, "OutputType"),
    outputData = i(7, "outputData")
  }, { delimiters = "[]" })),

  s("jest.mock-module-partial", fmt([=[
      jest.mock<typeof import('[module_path]')>('[module_path]', () => ({
        __esModule: true,
        ...jest.requireActual('[module_path]'),
        default: jest.fn((...args) => value); // if you want to override the default export
        [member_to_override]: jest.fn((...args) => value) // or if you don't need metadata of mock: () => value
      }));

      // Real-world example that tracks mock function inside of higher order function
      // The tricky part is that the anonymous function has a new ref with each call in the code,
      // but we need to track it, so we return a ref to the same function on each call by
      // creating it first as a constant. Also the module being mocked must be in
      // beforeAll so that the mock functions are initialized for
      // injection.
      //
      // const mockGetLabels = jest.fn(); // injected as anonymous function / lambda
      // const mockGetLabelsGetter = jest.spyOn(JiraWebClient.rest, 'getLabels', 'get'); // spies on accessor of key getLabels
      //
      // beforeAll = (() => {
      //  jest.mock('../../../shared/jira/jira-web-client.ts', () => ({
      //    __esModule: true,
      //    ...jest.requireActual('../../../shared/jira/jira-web-client.ts'),
      //    JiraWebClient: { rest: { getLabels: [[mockGetLabels, (jest.fn())()]] }}
      //  }));
      // )}
  ]=], { module_path = i(1, "path/to/module"), member_to_override = i(2, "member") },
    { delimiters = "[]", repeat_duplicates = true })),

  s("jest-fetch-mock-full-docs", fmt([=[
    /**
     *  Fetch Mock mocks the Global Fetch API (fetch)
     *  Default response code is 200
     *
     *  Response
     *  Define in arg1 or mock or as property of first arg.
     *
     *  Mock Setup Methods
     *  mock({matcher|url, headers})
     *  mock({matcher|url, headers}, response)
     *  mock({matcher|url, headers, response})
     *  mock(matcher|url, response, options) // splits matching into two params: arg0, arg2
     *
     *  A matcher: A predicate function which takes a route definition object as
     *  input, and returns a function of the signature (url, options, request) =>
     *  Boolean.
     *
     *  Stub fetch and define a route .mock(matcher, response)
     *  Stub fetch without a route .mock()
     *  Spy on calls, letting them fall through to the network .spy()
     *  Let specific calls fall through to the network .spy(matcher)
     *  Respond with the given response to any unmatched calls .catch(response)
     *  Add a mock that only responds once .once(matcher, response)
     *  Add a mock that responds to any request .any(response)
     *  Add a mock that responds to any request, but only once .anyOnce(response)
     *  Add a mock that only responds to the given method .get(), .post(), .put(), .delete(), .head(), .patch()
     *  Combinations of the above behaviours getAny(), getOnce(), getAnyOnce(), postAny() ...
     *
     *  Tear Down
     *
     *  Remove all mocks and history .restore(), .reset()
     *  Discard all recorded calls, but keep defined routes .resetHistory()
     *  Discard all routes, but keep defined recorded calls.resetBehavior()
     *
     *  Patterns
     *
     *  Match any url '*'
     *  Match exact url 'http://example.com/users/bob?q=rita'
     *  Match beginning 'begin:http://example.com'
     *  Match end 'end:bob?q=rita'
     *  Match path 'path:/users/bob'
     *  Match a glob expression 'glob:http://example.{com,gov}/*'
     *  Match express syntax 'express:/users/:name'
     *  Match a RegExp /\/users\/.*/
     *
     *  Naming routes
     *
     *  When defining multiple mocks on the same underlying url (e.g. differing
     *  only on headers), set a name property on the matcher of each route.
     *
     *  fetch('http://example.com/users/bob?q=rita', {
     *       method: 'POST',
     *       headers: { 'Content-Type': 'application/json' },
     *       body: '{"prop1": "val1", "prop2": "val2"}',
     *     });
     *
     *  fetchMock.called(matcher) reports if any calls matched your mock (or leave matcher out if you just want to check fetch was called at all).
     *  fetchMock.lastCall(), fetchMock.lastUrl() or fetchMock.lastOptions() give you access to the parameters last passed in to fetch.
     *  fetchMock.done() will tell you if fetch was called the expected number of times.
     *
     *  All methods are chainable so you can define multiple mocks in a single call.
     *  fetchMock
     *   .get('http://good.com/', 200)
     *   .post('http://good.com/', 400)
     *   .get(/bad\.com/, 500)
     *
     *  fetchMock.mock(matcher, response), where matcher is an exact url or regex to match, and response is a status code, string or object literal.
     */
     // Mock the fetch() global to return a response
     fetchMock.get(
       'http://httpbin.org/my-url',
       { hello: 'world' },  // response body
       { delay: 1000, // fake a slow network
         headers: {
         user: 'me' // only match requests with certain headers
       }
     });

     makeRequest().then(function(data) {
       console.log('got data', data);
     });

     // Unmock.
     fetchMock.reset();
  ]=], {}, { delimiters = '[]' })),
  s("jest-fetch-mock-overloads", fmt([[
    // mock({matcher|url, headers})
    // mock({matcher|url, headers}, response)
    // mock({matcher|url, headers, response})
    // mock(matcher|url, response, options) // splits matching into two params: arg0, arg2
  ]], {}, { delimiters = "[]" })),
  s("jest-fetch-mock-function", fmt([[
    // .mock(
      matcher: String | Regex | Function | Object,
      response: String | Object | Function | Promise | Response,
      options: Object) // configure matching and responding behaviour
    fetchMock
      .mock((url, options) => {
        // logic here
      }, response)
  ]], {}, { delimiters = "[]" })),

  s("jest-fetch-mock-get-syntax", fmt([[
    fetchMock.get()
  ]], {}, { delimiters = "[]" })),

  s("jest-fetch-mock-add-custom-shorthand-extension", fmt([[
    /** Defines "purge" as shorthand for a mock analogous to "get"
    fetchMock.purge = function (matcher, response, options) {
      return this.mock(
        matcher,
        response,
        Object.assign({}, options, {method: 'PURGE'})
      );
    }
  ]], {}, { delimiters = "[]" })),

  s("jest-fetch-mock-request-response-syntax", fmt([[
    const mockPost = () => {
      const request = {
        name: 'unique_name_of_this_request',
        url: new URL('/path_segment', 'https://domain'),
        method: 'POST',
      };

      const response = {
        responseStatus: 200,
        responseBody: {},
      };
      fetchMock.mock(request, response);
    };
  ]], {}, { delimiters = "[]" })),

  s("jest-mock-e2e-setup", fmt([[
    jest.mock('./setup', () => ({
      __esModule: true,
      ...jest.requireActual('./setup'),
      getDtpClientId: jest.fn(() => 'some-client-id'),
      getDtpEnvironmentUrl: jest.fn(() => 'https://some-environment-url'),
      getDtpClientSecret: jest.fn(() => 'some-client-secret'),
      getDtpSSOUrl: jest.fn(() => 'https://some-sso-endpoint')
    }));
  ]], {}, { delimiters = "[]" })),

  s("jest-function-mock", fmt([[
    jest.fn() as jest.MockedFn<{fn_type}>
  ]], { fn_type = i(1, "fn_type") }, { delimiters = "{}" })),
  s("beforeEach", fmt([[
    beforeEach(() => {[]})
  ]], {i(1)}, {delimiters="[]"})),
}
