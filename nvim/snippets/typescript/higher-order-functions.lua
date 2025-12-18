return {
  s("reduce", fmt([=[
    const f = <A extends {key: string, value: string},B,>(ps: Array<A>): {result: B} => ({
      result: ps.reduce((acc, next, _) => ({ ...acc, [[next.key]]: next.value }), {}),
    });
  ]=], {}, {delimiters="[]"})),
  s("flatten", fmt([=[
    Array.flat()
  ]=], {}, {}))
}

