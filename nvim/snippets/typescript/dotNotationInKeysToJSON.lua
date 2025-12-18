return {
  s("dotNotationInKeysToJSON", fmt([=[
  /** Converts properties like `'data.currentState': '{"kind":"Hotfix"}`
 * to proper JSON.
 */
export const dotNotatedStringToJSONObject = <K extends string, V extends string>([[key, value]]: [[K, V]]) => {
  const expandKeysToJSON = (path: K, val: V) => {
    const parts = path.split('.');
    if (parts.length <= 1) {
      return { [[path]]: val };
    }
    // eslint-disable-next-line @typescript-eslint/no-non-null-assertion
    const last = parts.pop()!;
    return parts.reduceRight(
      (acc, v) => {
        if (v === 'data') {
          return acc;
        }
        return {
          [[v]]: acc,
        };
      },
      // eslint-disable-next-line @typescript-eslint/no-unsafe-assignment
      { [[last]]: tryJSONParse(val) },
    );
  };

  return expandKeysToJSON(key, value);
};
  ]=], {}, {delimiters="[]"}))
}
