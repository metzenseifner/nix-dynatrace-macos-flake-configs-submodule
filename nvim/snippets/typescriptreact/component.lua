return {
  s("component-new", fmt([[
    import React from 'react';
    type [component]Props = null;
    export const [component] = (props: [component]Props) => {
      return <>[codehere]</>;
    }
  ]], {component = i(1, "component"), codehere = i(2)}, {delimiters="[]", repeat_duplicates=true})),
  s("component", fmt([=[
import { AutomationCodeEditor } from '@dynatrace/automation-action-components';
import { FormField, FormFieldMessages, Label } from '@dynatrace/strato-components-preview';
import React from 'react';

export [ComponentNameF]TestIds = {
  [LabelF]: "[ComponentNameF].[LabelF]"
} as const

export interface [ComponentNameF]Props {
  value?: string;
  onChange: (value: string) => void;
  'data-testid'?: string;
}

export const [ComponentName] = (props: [ComponentNameF]Props) => {
  return (<>
    <FormField required={true}>
      <Label>[Label]</Label>
      <AutomationCodeEditor value={props.value} onChange={props.onChange} data-testid={[ComponentNameF]TestIds.[LabelF]} />
      <FormFieldMessages.Item>The full content of the file.</FormFieldMessages.Item>
    </FormField>
  </>);
};
  ]=], {
    ComponentName = i(1),
    ComponentNameF = f(function(values) return values[1][1] end, { 1 }),
    Label = i(2, "Label"),
    LabelF = f(function(values)
      local lowerCamelCase = values[1][1]:gsub("^%u", string.lower)
      return lowerCamelCase
    end, { 2 })
  }, { delimiters = "[]", repeat_duplicates = true })),
  s("component-without-fetch", fmt([=[
import { AutomationCodeEditor } from '@dynatrace/automation-action-components';
import { FormField, FormFieldMessages, Label } from '@dynatrace/strato-components-preview';
import React from 'react';

export [ComponentNameF]TestIds = {
  "[ComponentName].labelName"
} as const

export interface [ComponentNameF]Props {
  'value'?: string;
  'onChange': (value: string) => void;
  'data-testid'?: string;
}

export const [ComponentName] = (props: [ComponentNameF]Props) => {
  return (<>
    <FormField required={true}>
      <Label>[Label]</j>
      <AutomationCodeEditor value={props.value} onChange={props.onChange} data-testid={[ComponentNameF]TestIds.[Label]} />
      <FormFieldMessages.Item>The full content of the file.</FormFieldMessages.Item>
    </FormField>
  </>);
};
  ]=], {
    ComponentName = i(1),
    ComponentNameF = f(function(values) return values[1][1] end, { 1 }),
    Label = f(function(values)
      local lowerCamelCase = values[1][1]:gsub("^%u", string.lower)
      return lowerCamelCase
    end, { 2 })
  }, { delimiters = "[]", repeat_duplicates = true })),
  s("component-setup", fmt([=[
<[ComponentName] value={props.value} onChange={props.onChange} data-testid={[ComponentName]TestIds.[Label]} />
  ]=], { ComponentName = i(1, "ComponentName"), Label = i(2, "Label") }, { delimiters = "[]", repeat_duplicates = true })),
}
