return {
  s("zulu_to_cet", { t("const zulu_to_cet = (zulu = new Date()) => new Date(zulu.setHours(zulu.getHours() + 1))") }),
  s("format_timestamp", fmt([[
      /**
        *  @returns - string formatted as YYYY-mm-dd HH:MM:SS+0100
        */
      const format_date = (dateTimeObject) => {
        const pad = (char) => (total_chars) => (value) => value.toString().padStart(total_chars, char);
        const pad_zero = pad('0')(2)
        return `${dateTimeObject.getFullYear()}-${pad_zero(dateTimeObject.getMonth()+1)}-${pad_zero(dateTimeObject.getDate())} ${pad_zero(dateTimeObject.getHours())}:${pad_zero(dateTimeObject.getMinutes())}:${pad_zero(dateTimeObject.getSeconds())}+0100`
      }
  ]], {}, { delimiters = "[]" }))
}
