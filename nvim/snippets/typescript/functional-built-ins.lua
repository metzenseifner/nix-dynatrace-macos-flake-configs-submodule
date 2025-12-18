return {
  s("groupBy", fmt([[
    Object.groupBy([1, 2, 3, 4, 5, 6, 7, 8, 9], v => (v % 2 ? "odd" : "even"));
    // {{ odd: [1, 3, 5, 7, 9], even: [2, 4, 6, 8] }};
    Map.groupBy([1, 2, 3, 4, 5, 6, 7, 8, 9], v => (v % 2 ? "odd" : "even"));
    // {{ odd: [1, 3, 5, 7, 9], even: [2, 4, 6, 8] }};

  ]], {}, { delimiters = "{}" })),
  s("groupBy-Typescript", fmt([[
    const groupBy = <T>(array: T[], predicate: (value: T, index: number, array: T[]) =
      array.reduce((acc, value, index, array) => {{
        (acc[predicate(value, index, array)] ||= []).push(value);
        return acc;
      }}, {{}} as {{ [key: string]: T[] }});
  ]], {}, {delimiters="{}"})),
}
