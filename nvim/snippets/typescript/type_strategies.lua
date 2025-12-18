return {
  s("defineKeys", fmt([=[
  function defineKeys<T extends Record<string, unknown>>(def: T) {{
  return {{
    def,
    keys: Object.keys(def) as (keyof T)[]
  }};
}}

const {{ def: serviceInfoDefinition, keys: serviceInfoKeys }} = defineKeys({{
  Cluster: '',
  Namespace: '',
  Service: '',
  Team: ''
}});
export type ServiceInfo = typeof serviceInfoDefinition;

  ]=], {}, { delimiters = "{}" }))
}
