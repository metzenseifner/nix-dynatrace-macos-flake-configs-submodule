local get_visual_selection = function(args, parent)
  if (#parent.snippet.env.LS_SELECT_RAW > 0) then
    return sn(nil, t(parent.snippet.env.LS_SELECT_RAW))
  else -- If LS_SELECT_RAW is empty, return a blank insert node
    return sn(nil, t(parent.snippet.env.LS_SELECT_RAW))
  end
end

return {
  s("toInteger", fmt([[
    parseInt(<value>)
  ]], {value = d(1, get_visual_selection)}, {delimiters="<>"})),
  s({ trig = "isInSet", desc = "Predicate: Set Membership: Inclusion" }, fmt([[
    <arraysymbol>.includes(<value>);
  ]], { value = d(1, get_visual_selection), arraysymbol = i(2, "array_symbol") }, { delimiters = "<>" })),
  s("Object.entries", fmt([[
  /**
    * A typed version of Object.entries.
    */
   export function objectEntries<T extends Record<PropertyKey, unknown>, K extends keyof T, V extends T[K]>((o: T)) {
     return Object.entries((o)) as [K, V][];
   }
  ]], {}, { delimiters = "()" })),
  s("throw-not-yet-implemented", fmt([[
    throw new Error(`Not yet implemented`);
  ]], {}, {})),
  s("isTypeOrThrow", fmt([[
    function assertsIsUrl(value: any): asserts value is URL {
      new URL(value);
    }
  ]], {}, { delimiters = "<>" })),
  s("record-filter", fmt([==[
    const isFieldRequired = <K extends keyof FieldsRecord,>(field: [K, FieldsRecord[K]]) => field[1].required;
  ]==], {}, { delimiters = "{}" })),
  s("for-of", fmt([[
    for (let elem of iterable) {
    }
  ]], {}, { delimiters = "[]" })),
  s("switch", fmt([[
    switch(action) {
      case 'prefix':
        throw new Error(`Not yet implemented`);
        break;
      case 'suffix':
        throw new Error(`Not yet implemented`);
        break;
      default:
        break;
    }
  ]], {}, { delimiters = "<>" })),
  s("action-spec", fmt([=[
    // A declarative way to express actions decoupled from their implementations.
    /**
     * Define interfaces for all actions
     */
    interface PrefixAction {
      name: 'prefix';
      args: [string, string];
    }
    interface SuffixAction {
      name: 'suffix';
      args: [string, string];
    }
    interface BogusAction {
      name: 'bogus';
      args: [number, string];
    }

    /* Union of all available actions */
    type Action = PrefixAction | SuffixAction | BogusAction;

    /**
     * Prerequisite: A union of all possible combinations named Action in this example.
     *
     * Use a mapped type { [K in Action['name']]: resultType }
     * whereby the resultType is whatever the output shape should be.
     *
     * The Extract Utility returns a subset of all types based on a pattern shape or never.
     *
     * Note that the result of the mapped type will be a type with the shape
     *
     * {
     *   Action['name']: resultType
     * }
     *
     * To extract the resultType, index into the mapped type using the
     * same indexed type used for the mapped type i.e. Action['name']
     */

    /* Example where resultType is a named tuple (which has no semantics/syntax of value and is effectively an unnamed tuple) */
    type PossibleTuplesV1 = {
      [K in Action['name']]: [name: K, args: Extract<<Action, { name: K }>>['args']];
    }[Action['name']];

    /* Example where resultType is an unnamed tuple (same as named at runtime) */
    type PossibleTuplesV2 = {
      [K in Action['name']]: [K, Extract<<Action, { name: K }>>['args']];
    }[Action['name']];

    /* Example where resultType is a flattened named tuple (args would have been a nested tuple/array) */
    type PossibleTuplesV1 = {
      [K in Action['name']]: [name: K, ...args: Extract<<Action, { name: K }>>['args']];
    }[Action['name']];

    // The following are equivalent in terms of semantics and instantiation syntax e.g.['prefix', ['displayName', 'my.']]
    // prefer ActionsSpecV1 / PossibleTuplesV1 because it gives the programmer more info about the intended semantics of the type while writing code.
    type ActionsSpecV1 = PossibleTuplesV1; /* type = [name: "prefix", args: [string, string]] | [name: "suffix", args: [string, string]] | [name: "bogus", args: [number, string]] */
    type ActionsSpecV2 = PossibleTuplesV2; /* type = ["prefix", [string, string]] | ["suffix", [string, string]] | ["bogus", [number, string]] */
  ]=], {}, { delimiters = "<>" })),
  s("dtp-sourcemaps", fmt([[
    build: {
      functions: {
        sourceMaps: true
      }
    }
  ]], {}, { delimiters = "<>" })),

  s("dtp-intents", fmt([=[
    // app.intents app shell finds apps capabable of handling intent event
    // based this object. Ties are broken with /intent/:intentId
    intends: {
      '<intentname>':
        description: '<description>'
        // value: obj whereby keys are payload props and keys' values
        // define prop shape + isRequired
        properties: {
          required: <isRequired>
          // Some examples of defining datatypes in schema:
          schema: {
            type: "string",
            // string|null: ["string", "null"]
            type: "array",
            items: {
              type: "string"
            },
            type: "object"
            properties: {
              prop1: {
                type: 'string'
              }
            }
          }
        }
    }
  ]=], {
      intentname = i(1, "intent-name"),
      description = i(2, "description"),
      isRequired = i(3, "true")
    },
    { delimiters = "<>" })),

  s("e2e-setup-auth", fmt([=[
    /**
     * Verifies that the test user/password is set and
     * proceeds to login via SSO or default login when running in CI context.
     */
    export async function setup(controller: TestController, goto: AppUrl = ''): Promise<void> {
      await controller.useRole(userRole);
      // size due to limitation of the design-systems page layout components that require a wide screen
      await controller.resizeWindow(1600, 900);
      if (goto) {
        await controller.navigateTo(goto);
      }
      await controller.switchToIframe(iframeSelector);
    }
  ]=], {}, { delimiters = "[]" })),

  s("action-base-action-dynatrace", fmt([[
    import { BaseAction } from '@dynatrace/sdk-automation-labs/lib/actions';
    import { z } from 'zod';
    import { Connection } from '../../shared/connections/jira-connection';
    import { DeploymentType, JiraDeploymentTypeClient } from '../../shared/jira/jira-deploymentType-client';
    import { typeCheck } from '../../shared/util/type-checker';
    import { [ServersideFunction]Payload } from '../public/[serversidefunction]';

    const [ServersideFunction]PayloadSchema = z.object({
      connectionId: z.string(),
    });

    export class [Action]Action extends BaseAction<[ReturnType]> {
      private payload!: [ServersideFunction]Payload;

      /** Validates payload */
      protected async initialize(rawPayload: [ServersideFunction]Payload): Promise<[ReturnType]> {
        const parserResult = [ServersideFunction]PayloadSchema.safeParse(rawPayload);
        if (!parserResult.success) {
          throw new Error(`Ùnable to validate payload!\nPlease check all input fields.`);
        }
        this.payload = parserResult.data;
      }

      /** Executes Workflow Action */
      protected async run(): Promise<[ReturnType]> {
        // Do something with payload (input) here
        await client
          .effect(this.payload.thingId)
          .verify(z.any())
          .catch((e: Error) => {
            throw new Error(`[Action] failed to execute as expected: ${ex.message}`);
          });
      }
    }


  ]], {
    ServersideFunction = i(1, "ServersideFunction"),
    serversidefunction = i(2, "serverside-function"),
    Action = i(3, "Some"),
    ReturnType = i(4, "ReturnType")
  }, { delimiters = "[]", repeat_duplicates = true })),


  s("api-action-serverside-function", fmt([[
      import { ActionResult } from '@dynatrace/sdk-automation-labs/lib/actions';
      import { [Action]Output, [Action]Action } from '../actions/[actionfile]';
      import { JiraServerlessFunctionBaseParameters } from '../../shared/jira/jira-web-client';

      export interface [Action]Input extends JiraServerlessFunctionBaseParameters {
      }


      /** Server-side Function :: P -> Q",
       *
       * whereby P enforces the input type and Q suggests the output type",
       * exposed to the browser.",
       * Exposed as a serverless function via the relative URL /api/"
       *
       * await fetch('/api/')
       */
      export default async function (payload?: [Action]Input): Promise<ActionResult<[Action]Output>> {
        if (!payload) {
          throw new Error('Payload must be defined, but was undefined.');
        }
        return new [Action]Action().runAction(payload);
      }

  ]], {
    Action = i(1, "ActionName"),
    actionfile = i(2, "action-file"), -- TODO consider making this a select option box based on files in actions dir
  }, { delimiters = "[]", repeat_duplicates = true })),

  s("api-function-serverside-call", fmt([[
    // npm install --save-dev @dynatrace/util-app
    //import { functions } from '@dynatrace/util-app';
    /** React Component call of API Function */
    const <output> = async (payload: Input) =>> functions.call('<funcfilename>', payload)
      .then((r) =>> typecheck(r))
      .then((r) =>> r as R); // typecast to type we know it to be
  ]], { output = i(1, "output"), funcfilename = i(2, "func_file_name_no_ext") }, { delimiters = "<>" })),
  s("log-action-payload", fmt([[
    console.log(`Payload: ${JSON.stringify(this.payload)}`);
  ]], {}, { delimiters = "[]" })),

  s("api-function-dynatrace-serverside", fmt([[
    import { functions } from '@dynatrace/util-app';
    import { z } from 'zod';
    import { applySchemaOrThrow } from '../../shared/util/validators';

    export const InputSchema = z.object({
      id: z.string(),
      name: z.string(),
    });
    export type Input = z.TypeOf<typeof InputSchema>;

    export const OutputSchema = z.object({});
    export type Output = z.TypeOf<typeof OutputSchema>;

    export default async function (payload?: Input): Promise<Output> {
      const validatedPayload = applySchemaOrThrow(
        InputSchema,
        payload,
        `Payload was invalid. Please provide a valid payload.`,
      );

      try {
        const output = await someExternalService(validatedPayload.id)
          .then((r) => r.json)
          .then(typecheck)
          .then((v) => v as Output);

        return output;
      } catch (error) {
        if (error instanceof Error) throw new Error(`Error occurred: ${error.name}(${error.message})`);
      }
    }
  ]], {}, { delimiters = "[]" })),

  --s("tenant-url", c(1, {
  --  t("https://vzx38435.dev.apps.dynatracelabs.com"),
  --  t("https://yhf92160.sprint.apps.dynatracelabs.com"),
  --}))
  --
  s("log-variable", fmt([[
    console.debug(`[a]: ${JSON.stringify([a])}`);
  ]], { a = i(1, "a") }, { delimiters = "[]", repeat_duplicates = true })),

  s("peek", fmt([=[
    // For easy debugging of synchronous FP code. Augments Array.prototype with peek function (provides dot notation).
    // @Usage
    // [[1,2,3]].peek().map(v => v + 1).peek(prefix: "After: ")
    Object.defineProperty(Array.prototype, 'peek', {value: function(prefix="Peek: ") { console.debug(`==> ${prefix}${JSON.stringify(this)}`); return this; }});

    /** For synchronous FP code, but requires array.
      * @Usage
      * .then(peek)
      */
    const peek = <A>(a: A): A => {
      console.debug(`Peek: ${JSON.stringify(a)}`);
      return a; // usually <M<a>> because this function is not useful without a monad.
    };

    // For debugging asynchronous promise chain value. Returns a function that works within a promise chain accepting an effect. Beware that Reponse should be cloned because .json and .text streams may be accessed once.
    const createPeek =
      (peekEffect = <T>(v: T) => console.log(`Status: ${JSON.stringify(v)}`)) =>
      async <T>(value: T): Promise<T> => {
        if (value instanceof Response) {
          const clonedValue = value.clone();
          peekEffect(clonedValue);
        } else {
          peekEffect(value);
        }
        return Promise.resolve(value);
      };
    const peek = createPeek(value => console.log(`Peek: ${value}`));
  ]=], {}, { delimiters = "[]" })),


  s("expect-nothrow", fmt([[
    expect(() => [f]).not.toThrow(error);
  ]], { f = i(1, "Function") }, { delimiters = "[]" })),

  s("jest-mock", fmt([[
    jest.mock('[module]', () => {
      const originalModule = jest.requireActual('[module]');
      /* Returns Object that represents all exported functions and data */
      return {
        __esModule: true,
        default: jest.fn(() => 'mocked default export'),
        foo: 'mocked function called foo',
      };
    });
  ]], { module = i(1, "MODULE_IMPORT_PATH") }, { delimiters = "[]", repeat_duplicates = true })),

  s("beforeAll", fmt([[
    beforeAll(() => {
      [content]
    });
  ]], { content = i(1) }, { delimiters = "[]" })),

  s("jest-mock-class-as-named-export", fmt([[
    // TODO unfinished!
    //https://github.com/facebook/jest/issues/8532
    // https://stackoverflow.com/questions/56436050/how-to-mock-an-es6-class-that-is-a-named-export-in-jest
    // Does not work because automocks work with default mocks
    // So instead use a module factory parameter + manual mock of a constructor function
    // manual mocks require mocking the module jest.mock('./mod')
    // The factory fn must return a constructor function
    // jest.mock(path, moduleFactory) takes a module factory argument. A module factory is a function that returns the mock.
    jest.mock('../../shared/util/logger', () => ({
      // jest.mock(path, moduleFactory) takes a module factory argument. A module factory is a function that returns the mock.
      ConsoleLogger:

    }));// default export class mocked
  ]], {}, { delimiters = "[]" })),

  s("jest-mock-method-broken-approach", fmt([[
    const logInfoSpy = jest.fn();
    const a = jest.mocked(ConsoleLogger).mockImplementation(() => {
      return {
        ...MockedLogger,
        info: logInfoSpy,
      };
    });

    // instead use

    jest.mocked(ConsoleLogger).mockImplementation(() => {
      return {
        ...MockedLogger,
      };
    });
    const logInfoSpy = jest.spyOn(ConsoleLogger.prototype, 'info');
  ]], {}, { delimiters = "[]" })),

  s("destructure-array-in-function-args", fmt([=[
    function f([x, y], ...rest) {
      // x is bound to array[0]
      // y is bound to array[1]
      // rest is bound to array[2:-1] using spread operator
    }
  ]=], {}, { delimiters = "<>" })),

  s("actionspec", fmt([=[
    /** Applies prefix at JSON path arg[0] of string arg[1] */
    export interface PrefixAction {
      verb: 'prefix';
      args: [string, string];
    }

    /** Applies suffix at JSON path arg[0] of string arg[1] */
    export interface SuffixAction {
      verb: 'suffix';
      args: [string, string];
    }

    /* Union of all available actions */
    export type Action = PrefixAction | SuffixAction;

    /**
     * Defines an extensible interface for declarative approach to actions in the dtp.config.ts
     *
     * Extract Utility Function returns all types from a union type that would be assignable to a target Union type.
     * Extract<<FromUnionType, PartiallyMatchThisType>>
     */
    export /* for tests */ type ActionSpec = {
      [K in Action['verb']]: [verb: K, ...args: Extract<<Action, { verb: K }>>['args']];
    }[Action['verb']];
  ]=], {}, { delimiters = "<>" })),

  s("delay", fmt([=[
    const delay = <T>(t:number, v: T): Promise<T> => {
        return new Promise(resolve => setTimeout(resolve, t, v));
    }
    // Usage Example:
    // return JiraWebClient.getDeploymentType({ connectionId: conn })
    //   .then((value) => delay(1000, value))
    //   .then((deployTypeStr) => {
    //     return applySchemaOrThrow(DeploymentTypeSchema, deployTypeStr, `Unknown deployment type: ${deployTypeStr}`);
    //   })

    // To extend the Promise<T> type include the delay function, it is more complicated:
    // 1. Define a new type that takes all functions from original type and appends the delay function to it.
    // 2. Overload the .then and .catch functions' domains to accept delay method
    // 3. Inform typescript of prototype change to include delay function
    //Promise.prototype[['delay']] = function(t) {
    //    return this.then(function(v) {
    //        return delay(t, v);
    //    });
    //}
  ]=], {}, { delimiters = "[]" })),

  s("block-timer-delay-sleep-function-start-promise-chain", fmt([[
    const blockForMillis = (milliseconds: number) => () => new Promise((resolve) => setTimeout(resolve, milliseconds));
    const blockFor500Millis = blockForMillis(500);
    return blockFor500Millis.then(_ => Promise.resolve(somethingElse));
  ]], {}, { delimiters = "[]" })),

  s("block-timer-delay-sleep-function-mid-promise-chain", fmt([[
    //await new Promise(r => setTimeout(r, 300_000))
    const blockForSeconds = (seconds: number) => <T>(value: T): Promise<T> => {
      return new Promise((resolve, reject) => {
        console.debug(`Blocking execution for ${seconds}s`);
        setTimeout(() => {
          console.debug(`Unblocking execution because ${seconds}s have elapsed.`);
          resolve(value);
        }, seconds * 1000);
      });
    }

    const blockFor10Seconds = blockForSeconds(10);

    return client
      .getDeploymentType()
      .then(blockFor10Seconds)
      .then(ok)
  ]], {}, { delimiters = "[]" })),

  s("unique", fmt([[
    // indexOf compares ref ids, not values.
    const isUniqueByRef = (currentValue, index, array) => array.indexOf(currentValue) === index
    // findIdex compares by values, not refs, which allows for basing uniqueness on members of the object
    const isUniqueByValue = (currentValue, index, array) => array.findIndex(v => v.member === currentValue.member) === index

    list.filter(isUniqueByRef)
  ]], {}, {})),
  s("reduce-to-Object-from-pairs", fmt([=[
    //list.reduce((accumulator, currentValue, index, array) =>> , initialValue)
    // Do not forget to wrap result of lambda in parentheses due to syntax ambiguity in Javascript: scope vs. object literal
    list.reduce((accumulator, currentValue, index, array) =>> ({...accumulator, [currentValue[0]]: currentValue[1]}), {})
  ]=], {}, { delimiters = "<>" })),
  s("reduce-to-Object-async-with-async-value-of-key", fmt([=[
    // Context-preserving fold (context under project key)
    const result = (await get_projects
      .projects
      .reduce(async (accumulatorP, value, index, array) => {
        const accumulator = await accumulatorP;
        return {...accumulator, [[value.repoSlug]]: { project: value, open_prs: (await fetch(url).flat().filter(id=>id) } };
      },
        {}
      ))
  ]=], {}, { delimiters = "[]" })),
  s("reduce-to-Map", fmt([[
    //list.reduce((accumulator, currentValue, index, array) => , initialValue)
    // reduce obj to map
    list.reduce((accumulator, currentValue, index, array) => accumulator.set(currentValue.member, currentValue), new Map())
  ]], {}, {})),
  s("reduce-to-Map-async", fmt([[
    // generally you do this if the currentValue has some asynchronous member
    list.reduce(async (accumulatorPromise, currentValue, index, array) => {
      const accumulator = await accumulatorPromise;
      return accumulator.set(currentValue.member, await currentValue.someAsyncMember)
    }
    , new Map()) // is a Promise of a Map
    ]], {}, { delimiters = "[]" })),
  s("reduce-to-Map-example", fmt([=[
    const isUniqueSlug = (value, index, array) => array.findIndex(v => v.repo.slug === value.repo.slug) === index
    const slugsToMap = get_projects
      .projects
      .filter(isUniqueSlug)
      .reduce((accumulator, value, index, array) => {
        return accumulator.set(value.repo.slug, {project: value, prs: getPRs(value.repo.namespace)([[value.repo.slug]])})
      },
        new Map()
      )

    // Returns Map of slug to awaited promise
    const slugsToAsyncMap = await get_projects
      .projects
      .filter(isUniqueSlug)
      .reduce(async (accumulatorP, value, index, array) => {
        const accumulator = await accumulatorP;
        return accumulator.set(value.repo.slug, {project: value, prs: await fetchPRs(value.repo.namespace)([[value.repo.slug]])})
      },
        new Map()
      )
  ]=], {}, { delimiters = "[]" }))


}
