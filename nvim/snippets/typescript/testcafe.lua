return {
  s("new TestBuilder", fmt([=[
    TestBuilder('[topic]')
    .withAuthor('jonathan.komar@dynatrace.com')
    .withTicket('[ticket]')
    .withTestScenario((testController) => {
      new EnterWorkflowsAppInteraction(testController)
      [content]
    })
    .build()
    .requestHooks()
    .skip;
  ]=], { topic = i(1, 'topic'), ticket = i(2, 'ticket'), content = i(3, '.nextChainCall') }, { delimiters = "[]" })),
  s("testcontroller-docs",
    t("https://testcafe.io/documentation/402632/api?search#test-controller-api")
  ),
  s("interaction", fmt([[
     // TODO: DELETEME use custom interaction class that extends TestController chain with methods
    .continueUsing(InteractionClass)
  ]], {})
  ),
  s("this.testController", {
    t("this.testController.expect(some_selector.exists)")
  }),

  s("testcafe-bootstrap", fmt([=[
     import { selectors } from 'your-selectors';

      const iframeSubSelector = Selector('iframe').withAttribute(
        'title',
        `${E2E_WORKFLOW_TASK_NAME}-${realAppId}:slack-send-message-widget`,
      );

     /**
       * https://bitbucket.lab.dynatrace.org/projects/lib/repos/testcafe-core/browse/src/runner/fixture-builder.ts?useDefaultHandler=true&at=b974cdec328283c450813b66178bcc6049e226d0#12
       *
       * build() returns a vanilla fixture function
       */
     new FixtureBuilder(`[TESTGROUP]`)
      .withBeforeEach(async (t) => {
        // t :: TestController exposes API assert functions and functions to interact with page

      })
      .build()
      // returns a fixture function, therefore any function applicable to the fixture function
      // can be called here. e.g. .before() .after()
      .after(async () => {
        printFailedRequests(requestLogger);
        console.log('Cleaning up..');
        // cleanup: delete settings objects created in before step
        });


      /**
        * https://bitbucket.lab.dynatrace.org/projects/lib/repos/testcafe-core/browse/src/runner/test-builder.ts?useDefaultHandler=true&at=b974cdec328283c450813b66178bcc6049e226d0#10
        *
        * build() returns a vanilla test function
        */
      new TestBuilder(`[TEST]`)
        .withAuthor('jonathan.komar')
        .withTicket('CA-1813')
        .withTestScenario(async (t) => {
          // t :: TestController exposes API assert functions and functions to interact with page
          await new Interaction(t)
            // avoid calling await anywhere within this chain of interaction functions
            .fluentApiSelectorFunc()
            .waitForSomething()
            // etc.
            .chainedfluentApiSelectorFunc();
        })
        .build()


  ]=], {
    TESTGROUP = i(1, "Represents group of tests or Web Page Under Test"),
    TEST = i(2, "Specific test")

  }, { delimiters = "[]" })),

  s({ ".else", ".ok" }, fmt([[
    // immediately following .expect(SELECTOR) Ensure predicate above holds
    .ok('<case_failure>')
  ]], { case_failure = i(1, "failure") }, { delimiters = "<>" })),

  s(".notOk", fmt([[
    // immediately following .expect(SELECTOR) Ensure predicate above is false after retries
    // number of retries settable: overload notOk arg[1] or in global assertionTimeout maybe?
    .notOk('<case_failure>')
  ]], { case_failure = i(1, "failure") }, { delimiters = "<>" })),

  --console.log(`[${new Date().toISOString()}] search (${keyword})`);


}
