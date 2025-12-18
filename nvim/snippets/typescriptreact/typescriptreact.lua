return {
  s("doc-html", { t("https://www.w3.org/TR/html-aria/#docconformance") }),

  s("intent", fmt([=[
    // If app has a React router, then route /intent/:intentId  required
    // <<Route path='intent'>><<Route path='some-api-func'>><</Route>>
    import { getIntent, IntentPayload } from '@dynatrace-sdk/navigation';
    import React, { useEffect } from 'react';
    useEffect(() =>> {
      const intent = getIntent();
      const id: string = intent.getId() // can be used to differentiate multiple intents
      const payload = intent.getPayload()
    }
    // Usually you want to redirect user back to original app so a sendIntent
    // can be used for that.
  ]=], {}, { delimiters = "<>" })),

  s("api-function-serverside-call", fmt([[
    // npm install --save-dev @dynatrace/util-app
    import { functions } from '@dynatrace/util-app';

    /**
      * Because DT Runtime maps HTTP path segments to API functions in dir, following is equivalent:
      * const responseFetchAPI = await fetch('/api/<funcfilename>', {method: 'POST', body: JSON.stringify(input)})
      *   .then((r) =>> r.json())
      */
    const responseSDK = await functions.call('<funcfilename>', input).then((r) =>> r.json());

    /** React Component call of API Function */
    const <funcsymbol> = useCallback(() =>> {
      (async (payload: Payload) =>> await functions.call('<funcfilename>', payload).then((r) =>> setValue(r)))({a: 'a'});
    }, []);
  ]], { funcsymbol = i(2, "funcsymbol"), funcfilename = i(1, "func_module_name_without_file_extension") },
    { delimiters = "<>" })),

  s("ui-integration-base-imports", fmt([=[
    import {
      findAllByRole,
      fireEvent,
      render,
      screen,
      userEvent,
      waitFor,
    } from '@dynatrace/wave-components-preview/testing';
    import '@testing-library/jest-dom';
    import 'jest-fetch-mock';
    import React from 'react';
    import { JiraWebClient } from '../../../../src/shared/jira/jira-web-client';
    import { <SUT> } from './<SUT>';

    describe('<SUT>', () =>> {

    }
  ]=], { SUT = i(1, "SUT") }, { delimiters = "<>", repeat_duplicates = true })),

  s("ui-integration-settings2.0", fmt([=[
    const Settings20URL =
      // eslint-disable-next-line no-secrets/no-secrets
      '/platform/classic/environment-api/v2/settings/objects?schemaIds=app%3Adynatrace.jira%3Aconnection&fields=objectId%2Csummary';
    const Settings20Response = {
      items: [
        {
          objectId: 'settings2.0-id',
          summary: 'Cloud Connection',
        },
        {
          objectId: 'settings2.0-id__v2',
          summary: 'CLICK\\_ME\\_CONNECTION',
        },
      ],
      totalCount: 2,
      pageSize: 100,
    };

    beforeEach(() =>> {
      jest.resetAllMocks();
      fetchMock.mockIf(Settings20URL, JSON.stringify(Settings20Response));
      // eslint-disable-next-line @typescript-eslint/no-unused-vars
      offsetWidth = jest.spyOn(window.HTMLElement.prototype, 'clientWidth', 'get').mockImplementation(() =>> 1000);
      // eslint-disable-next-line @typescript-eslint/no-unused-vars
      offsetHeight = jest.spyOn(window.HTMLElement.prototype, 'clientHeight', 'get').mockImplementation(() =>> 1000);
    }
  ]=], {}, { delimiters = "<>" })),

  s("action-dynatrace", fmt([=[
    import React from 'react';
    import { CustomInputEditor, FunctionProps, InputEditorWrapper, useWidgetValue } from '@dynatrace/sdk-automation-labs';
    import { ActionPayload } from '@dynatrace/sdk-automation-labs/lib/actions';
    import { Flex } from '@dynatrace/wave-components-preview';

    export type [InputPayload] = ActionPayload<ActionInput>;

    export const [ReactFCName]: CustomInputEditor<[InputPayload]> = (props: FunctionProps<[InputPayload]>) => {
      const { value, useDefaultValue, updateValue } = useWidgetValue<[InputPayload]>(props);
      useDefaultValue({
        // whatever implements [InputPayload]
      });

      return (
        <>
          <Flex gap={16} flexDirection='column'></Flex>
        </>
      );
    };

    [ReactFCName].displayName = '[ReactFCName]';

    export const [ReactFCName]Form: React.FunctionComponent = InputEditorWrapper(
      [ReactFCName] as CustomInputEditor<unknown>,
    );
  ]=], {
    InputPayload = i(1, "InputPayload"),
    ReactFCName = i(2, "ReactFCName"),
  }, {
    repeat_duplicates = true,
    delimiters = "[]"
  })),

  s("api-function-serverside-call", fmt([[
    // npm install --save-dev @dynatrace/util-app
    import { functions } from '@dynatrace/util-app';

    /**
      * Because DT Runtime maps HTTP path segments to API functions in dir, following is equivalent:
      * const responseFetchAPI = await fetch('/api/<funcfilename>', {method: 'POST', body: JSON.stringify(input)})
      *   .then((r) =>> r.json())
      */
    const responseSDK = await functions.call('<funcfilename>', input).then((r) =>> r.json());

    /** React Component call of API Function */
    const <funcsymbol> = useCallback(() =>> {
      (async (payload: Payload) =>> await functions.call('<funcfilename>', payload).then((r) =>> setValue(r)))({a: 'a'});
    }, []);
  ]], { funcsymbol = i(2, "funcsymbol"), funcfilename = i(1, "func_module_name_without_file_extension") },
    { delimiters = "<>" })),

  s("state-updateValue-callback", fmt([[
    ([value]) => updateValue({ [value] })
  ]], { value = i(1, "stateSymbol") }, { delimiters = "[]", repeat_duplicates = true })),

  s("useCallback", fmt([=[
    const action = useCallback(
      debounce((v: string) => {
        set[State](v);
      }, 350), [[set[State]]]);
  ]=], { State = i(1, "State") }, { delimiters = "[]", repeat_duplicates = true })),

  s("useEffect", fmt([=[
    useEffect(() => {
      props.on[action]({ key: key, value: value });
      debounce(() => {}, 350);
    }, [[props.on[action]]]);
  ]=], { action = i(1, "action") }, { delimiters = "[]", repeat_duplicates = true })),


  s("help-map-to-produce-elements", fmt([=[
    // https://legacy.reactjs.org/docs/lists-and-keys.html#keys
    // React components have "key" property; set to string ID as helper for React to detect changes.
    const listItems = [[1,2,3]].map((n) => <li key={id.toString()})
  ]=], {}, { delimiters = "[]" })),

  s("renderBuilder", fmt([=[
    import { RenderResult, render } from '@dynatrace/strato-components-preview/testing';
    import React from 'react';

    const rerenderBuilder =
      <Props extends object>(WidgetComponent: React.FunctionComponent<Props>, rerender: RenderResult[['rerender']]) =>
      (props: Props) =>
        rerender(<WidgetComponent {...props} />);

    /**
     * Higher-order render function abstraction
     *
     * Serves to
     *
     *  1. one-stop source of truth for component context changes making it
     *     easier to adapt tests to upstream changes to the Automation App and
     *     minimize verbosity of the tests.
     *  2. Keep JSX out of tests for cleaner tests.
     *
     * @returns a function that when given a React Function Component, returns a render function whose arguments are props.
     *
     * Usage:
     *   Partially apply:
     *    const renderSomeComponent = renderFunctionBuilder(SomeComponent)
     *   Reuse in tests:
     *    renderSomeWidget(someProps);
     */
    export const renderBuilder = <Props extends object>(WidgetComponent: React.FunctionComponent<Props>) => {
      const Inner = (props: Props) => {
        // eslint-disable-next-line testing-library/render-result-naming-convention
        const renderResult = render(<WidgetComponent {...props} />);
        return { ...renderResult, rerender: rerenderBuilder(WidgetComponent, renderResult.rerender) };
      };
      Inner.displayName = 'TestableFC';
      return Inner;
    };
  ]=], {}, { delimiters = "[]" })),
}
