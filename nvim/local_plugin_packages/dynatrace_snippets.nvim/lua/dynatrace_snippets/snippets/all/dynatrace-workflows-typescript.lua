return {
  s("results", fmt([[
    import { execution } from '@dynatrace-sdk/automation-utils';
    export default async function ({ execution_id }) {
      const execContext = await execution(execution_id);
      const result = await execContext.result("name_of_prev_task");
  }
  ]], {}, { delimiters = "<>" })),
  s("credentials-vault", fmt([[

    import { credentialVaultClient } from "@dynatrace-sdk/client-classic-environment-v2";
    export default async function () {
      const token = await credentialVaultClient.getCredentialsDetails({
        id: "[credentialId]",
      })
      .then((credentials)=> credentials.token)

      const fetchedThings = <T>(urls: Array<string>): Promise<Array<T> =>
        return urls.map(fetch(url, {
          method: 'GET',
          headers: {
            'Authorization': `Bearer ${token}`,
            'Accept': 'application/json'
          }
          })
          .then(response => {
            return response.json()
          })
          .then(data => data as T)
          );
    }
  ]], { credentialId = i(1, 'CREDENTIALS_VAULT-57F85C938292EF39') }, { delimiters = "[]" })),
  s("event-use", fmt([[
    import { execution } from '@dynatrace-sdk/automation-utils';
    export default async function ({ execution_id }) {
      const exec_obj = await execution(execution_id)
      const event = exec_obj.params.event
  ]], {}, { delimiters = "<>" })),
  s("format-timestamp", fmt([[
    export default async function () {

      /**
        *  @returns - string formatted as YYYY-mm-dd HH:MM:SS+0100
        */
      const format_date = (dateTime: Date) => {
        const pad = (char) => (total_chars) => (value) => value.toString().padStart(total_chars, char);
        const pad_zero = pad('0')(2)
        return `${dateTime.getFullYear()}-${pad_zero(dateTimeObject.getMonth()+1)}-${pad_zero(dateTimeObject.getDate())} ${pad_zero(dateTimeObject.getHours())}:${pad_zero(dateTimeObject.getMinutes())}:${pad_zero(dateTimeObject.getSeconds())}+0100`
      }

      const now = new Date();

      const timestamp_cet = format_date(now)

      const result = {
        timestamp_cet,
      }

      return result;
    }
  ]], {}, { delimiters = "[]" })),
  s("format-timestamp-from-event", fmt([==[
    import { execution } from '@dynatrace-sdk/automation-utils';

    export default async function ({ execution_id }) {
      const exec_obj = await execution(execution_id)
      const event = exec_obj.params.event

      const event_start = new Date(Date.parse(event[['event.start']]))
      const event_timestamp = new Date(Date.parse(event.timestamp))

      const t1 = new Date(event_start.setHours(event_start.getHours() + 1))
      const t2 = new Date(event_timestamp.setHours(event_timestamp.getHours() + 1))


      /**
        *  @returns - string formatted as YYYY-mm-dd HH:MM:SS+0100
        */
      const format_date = (t1) => {
        const pad = (char) => (total_chars) => (value) => value.toString().padStart(total_chars, char);
        const pad_zero = pad('0')(2)
        return `${t1.getFullYear()}-${pad_zero(t1.getMonth()+1)}-${pad_zero(t1.getDate())} ${pad_zero(t1.getHours())}:${pad_zero(t1.getMinutes())}:${pad_zero(t1.getSeconds())}+0100`
      }

      const event_start_cet = format_date(t1)
      const event_timestamp_cet = format_date(t2)

      const result = {
        event_timestamp_cet,
        event_start_cet,
      }

      return result;
    }
  ]==], {}, { delimiters = "[]" })),
}
