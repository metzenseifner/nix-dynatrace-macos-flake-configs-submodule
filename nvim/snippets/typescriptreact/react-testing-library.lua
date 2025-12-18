return {
  s("import-react-testing-lib", fmt([[
  import React from 'react';
  import {
    render,
    screen,
    waitFor,
    waitForElementToBeRemoved,
    within,
  } from '@dynatrace/strato-components-preview/testing';
  import '@testing-library/jest-dom';
  ]], {}, { delimiters = "[]" })),
  s("debug", fmt([[
    /**
      * Input:
      *   element: what should be printed
      *   maxLengthToPrint: default 7000 chars, truncate content
      *   options: an object containing keys to control output formatting
      *
      * screen.debug(element, maxLengthToPrint, options);
      *
      * Equivalent to
      *
      *   console.log(prettyDOM());
      *
      */
    screen.debug(undefined, null, { highlight: true })
  ]], {}, { delimiters = "<>" })),

  s("debug-prettyDOM", fmt([[
    console.log(`BEFORE::${prettyDOM()}`);
    fireEvent.click(screen.getByTestId('select-button'));
    console.log(`AFTER::${prettyDOM()}`);
  ]], {}, { delimiters = "<>" })),

  s("waitFor", fmt([[
      /**
        * Waiting for appearance of element
        *
        * Uses async wait utilities
        * See https://testing-library.com/docs/guide-disappearance
        *
        * using HTML attr data-testid="some-value" in JSX results in strings
        * in the DOM to precisely query for.
        *
        * @returns element: Promise<Element>
        * therefore always use await or .then(done)
        */
        await waitFor(() => {
          expect(screen.getByTestId('[]')).toBeInTheDocument();
        })
  ]], { i(1, "some-value") }, { delimiters = "[]" })),
}
