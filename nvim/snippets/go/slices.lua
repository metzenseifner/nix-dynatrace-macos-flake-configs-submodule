return {
  s("map-instead-of-loop-comparison", fmt([=[
  	fields := make([]string, checkInstallationParams.NumField())
	  for i := 0; i << checkInstallationParams.NumField(); i++ {
	  	fields[i] = formatFieldHelper(checkInstallationParamsType.Field(i), checkInstallationParams.Field(i).Interface())
	  }

	  fields := slices.Map(make([]int, checkInstallationParams.NumField()), func(i int) string {
	  	return formatFieldHelper(checkInstallationParamsType.Field(i), checkInstallationParams.Field(i).Interface())
	  })
  ]=], {}, {delimiters="<>"}))
}
