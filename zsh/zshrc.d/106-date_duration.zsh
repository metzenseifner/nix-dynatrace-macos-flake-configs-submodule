function duration() {
  # The easiest way to perform days count since a specifics day is to first get a number of seconds since epoch time ( 1970-01-01 ) for both dates. 
  local date1=$1
  local date2=$2
  # convert difference into days
  # $(($difference/(3600*24)))
  # whereby date is formatted like 2017-12-31 
  echo $((($(date +%s --date "$date2")-$(date +%s --date "$date1"))/(3600*24))) days
}
