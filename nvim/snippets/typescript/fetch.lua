return {
  s("fetch-get", fmt([[
    // Caveat: Returning await fetch directly will not execute side effects before returning.
    const [WHAT] =
    await fetch('[URL]', {method: 'GET', headers: {'content-type': 'application/json;charset=UTF-8'}})
      .then(isValidResponse)
      .then(parseJson)
      .then(peek)
      .catch(Promise.reject)
    return WHAT;
  ]], { URL = i(1, "https://"), WHAT = i(1, "WHAT") }, { delimiters = "[]" })),

  s("fetch-validator", fmt([[
    const createResponseValidator = (isValidReponse) => async (response: Response) => {
      if(isValidResponse(response)) {
        return Promise.resolve(response)
      } else {
        return Promise.reject(new Error(response));
      }
    }
    const isValidResponse = createResponseValidator((response:Response):boolean => response.status === 200 ? Promise.resolve(response) : Promise.reject(response))

    // Equivalent (will fail without the async if using above in Dynatrace JS Runtime Action)
    // const createResponseValidator = (isValidReponse) => async (response: Response) => {
    //   if(isValidResponse(response)) {
    //     return response
    //   } else {
    //     throw Error(response);
    //   }
    // }
    //const isValidResponse = createResponseValidator((response:Response):boolean => response.status === 200)
  ]], {}, { delimiters = "[]" })),
  s("peek-promise-function-with-side-effect", fmt([[
    // Caveat: Will yield incorrect side effect if JSON.stringify disabled for Response objects for security.
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
    const peekBody = createPeek((response) => console.log(`Peek: ${response.text()}`)); // will log Promise object because response.text() :: Promise<string>
  ]], {}, { delimiters = "[]" })),
  s("parseJson", fmt([[
    const parseJson = async (response: Response) => response.json();
  ]], {}, { delimiters = "[]" })),
  s("response-stream-to-string", fmt([[
    // decoded using UTF-8
    response.text()
  ]], {}, {}))




}
