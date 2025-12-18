return {
  s("FormField-required", fmt([=[
    <FormField required={true}>
      <Label>[Label]</Label>
      <[ComponentName] value={props.LabelCamelCaseL} onChange={props.onChange} data-testid={TestIds.[LabelCamelCaseL]} />
      <FormFieldMessages.Item>[Message]</FormFieldMessages.Item>
    </FormField>
  ]=], {
    Label = i(1, "Label"),
    LabelCamelCaseL = f(function(values) return values[1][1]:gsub("^%u", string.lower):gsub("%s+", "") end, { 1 }),
    ComponentName = i(2, "ComponentName"),
    Message = i(3, "Message"),
  }, { delimiters = "[]" })),
  s("updateValue", fmt([=[
([value]) => updateValue({ [value] })
  ]=], { value = i(1, value) }, { delimiters = "[]", repeat_duplicates = true })),
}
