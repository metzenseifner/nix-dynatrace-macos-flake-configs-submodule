return {
  s("workflow-info", fmt([[
    import {
      execution,
      actionExecutionId,
      executionId,
      taskName,
      workflowId,
    } from "@dynatrace-sdk/automation-utils";
  ]], {}, {delimiters="[]"})),
  s("repo-automation-utils",
    t("https://bitbucket.lab.dynatrace.org/projects/APPFW/repos/dynatrace-sdk/browse/packages/util/automation")),
  s("repo-client-automation",
    t("https://bitbucket.lab.dynatrace.org/projects/APPFW/repos/dynatrace-sdk/browse/packages/client/automation")),
  s("results-object-of-all-tasks", fmt([[
    // https://bitbucket.lab.dynatrace.org/projects/appfw/repos/dynatrace-sdk/browse/packages/client/automation/src/lib/apis/executions-api.ts?useDefaultHandler=true&at=092815cbf0bd92b45bd5a85ca877f577b48d37d5#186
    import { executionsClient } from '@dynatrace-sdk/client-automation';

    export default async function ({ execution_id }) {
      // load the execution object using the current execution_id
      var config = {executionId: execution_id}
      var tasks = await executionsClient.getTaskExecutions(config)

      console.log('Task Container', tasks)
    }
    // {
    //   task1: {
    //     id: "task1",
    //     execution: "9a13baba-fbb5-4513-b469-8d0f1ea6ff3b",
    //     name: "task1",
    //     state: "SUCCESS",
    //     stateInfo: null,
    //     input: {
    //       script: "// import of sdk modules\n" +
    //         "import { executionsClient } from '@dynatrace-sdk/client-automation';\n" +
    //         "\n" +
    //         "export default async function ({ execution_id }) {\n" +
    //         "  // load the execution object using the current execution_id\n" +
    //         "  var config = {id: execution_id}\n" +
    //         "  var myResult = await executionsClient.getExecution(config)\n" +
    //         "\n" +
    //         "  // log the result object\n" +
    //         "  console.log('My task result: ', myResult)\n" +
    //         "  console.log('only one variable: ', myResult.myVariable)\n" +
    //         "  return { task: 1 }\n" +
    //         "}"
    //     },
    //     startedAt: 2024-10-16T07:49:48.663Z,
    //     endedAt: 2024-10-16T07:49:49.454Z,
    //     runtime: 0,
    //     position: { x: 0, y: 1 },
    //     conditions: { states: {} },
    //     predecessors: [],
    //     active: true,
    //     result: { task: 1 },
    //     conditionResults: {}
    //   },
    //   tast2: {
    //     id: "tast2",
    //     execution: "9a13baba-fbb5-4513-b469-8d0f1ea6ff3b",
    //     name: "tast2",
    //     state: "RUNNING",
    //     stateInfo: null,
    //     input: {
    //       script: "// import of sdk modules\n" +
    //         "import { executionsClient } from '@dynatrace-sdk/client-automation';\n" +
    //         "\n" +
    //         "export default async function ({ execution_id }) {\n" +
    //         "  // load the execution object using the current execution_id\n" +
    //         "  var config = {executionId: execution_id}\n" +
    //         "  var tasks = await executionsClient.getTaskExecutions(config)\n" +
    //         "\n" +
    //         "  console.log('Task Container', tasks)\n" +
    //         "}"
    //     },
    //     startedAt: 2024-10-16T07:49:49.492Z,
    //     endedAt: 1970-01-01T00:00:00.000Z,
    //     runtime: 0,
    //     position: { x: 0, y: 2 },
    //     conditions: { states: { task1: "OK" } },
    //     predecessors: [ "task1" ],
    //     active: true,
    //     result: {},
    //     conditionResults: { states: { task1: true } }
    //   }
    // }
  ]], {}, { delimiters = "<>" })),
  s("timezone-offset", fmt([[
    /**
      * Calculate offset between Zulu and an arbitrary timezone in milliseconds.
      *
      * @remarks
      * The Data.prototype.getTimezoneOffset only calculates the offset from Zulu to
      * the current environment.
      *
      * @returns offset between Zulu and timezone in milliseconds.
      */
    const getTimezoneOffsetInMillis = (atTime=new Date(), timeZone="Europe/Vienna") => {
        const locale = "de-AT";
        const localizedTime = new Date(atTime.toLocaleString(locale, {timeZone}));
        const utcTime = new Date(atTime.toLocaleString(locale, {timeZone: "UTC"}));
        return Math.round((localizedTime.getTime() - utcTime.getTime()));
    }

    // Example Usage
    const timestamp_cet = t1 => new Date(t1.getTime() + getTimezoneOffsetInMillis())
  ]], {}, { delimiters = "[]" })),
  s("minutes-to-milliseconds", fmt([[
    const minutesToMillis = minutes => minutes * 60000;
  ]], {}, {})),
  s("timestamp-cet", fmt([[
    /**
      * ISO 8601 Specification costs money but the IETF RFC 3339 is a free "profile"
      * of the ISO 8601 Spec.
      *
      * Example 1937-01-01T12:00:27.87+00:20
      */
    export default async function () {
      // Sanity Check the Current Timezone on this tenant
      console.log(`Current Time on this tenant is: ${new Date()}`)

      /**
        *  @returns - string formatted as YYYY-mm-dd HH:MM:SS+0100
        */
      const format_date = (t1: Date) => {
        const pad = (char) => (total_chars) => (value) => value.toString().padStart(total_chars, char);
        const pad_zero = pad('0')(2)
        return `${t1.getFullYear()}-${pad_zero(t1.getMonth()+1)}-${pad_zero(t1.getDate())}T${pad_zero(t1.getHours())}:${pad_zero(t1.getMinutes())}:${pad_zero(t1.getSeconds())}+02:00`
      }

      const zulu_to_cet = (zulu = new Date()) => {
        return new Date(zulu.setHours(zulu.getHours() + 2))
      }

      const result = {
        timestamp_cet: format_date(zulu_to_cet()),
      }

      return result;
    }
  ]], {}, { delimiters = "[]" })),
  s("results-of-previous-group-by", fmt([[
    import {{ execution }} from '@dynatrace-sdk/automation-utils';

    export default async function ({{ execution_id }}) {{
      const execContext = await execution(execution_id);
      const open_prs = await execContext.result("query_open_prs");

      const result = Object.groupBy(open_prs.team_actor_prs, ({{repoSlug}}) => repoSlug)

      return {{...open_prs, team_actor_prs: result}};
    }}
  ]], {}, { delimiters = "{}" })),
  s("results-of-previous-task-list-to-string", fmt([[
    import {{ execution }} from '@dynatrace-sdk/automation-utils';

    export default async function ({{ execution_id }}) {{
      const execContext = await execution(execution_id);
      const open_prs = await execContext.result("group_by_repo");


      const pr_to_str = (ticket) =>
        `  • \`PR-${{ticket.prId}}\`: <${{ticket.url[0]}}|${{ticket.displayId}}> by <https://teams.internal.dynatrace.com/search/advanced?searchType=EMPLOYEE&employeeTypeFilter=MIXED&query=${{(() => ticket.author.replace(' ', '%20'))()}}|${{ticket.author}}>`

      const prs_to_str = (prs) => prs.map(pr_to_str).join('\n')
      const repo_to_str = (repoSlug) => `*${{repoSlug}}*`

      const team_actor_prs_content = Object.keys(open_prs.team_actor_prs)
        .sort()
        .map(k => `${{repo_to_str(k)}}\n${{prs_to_str(open_prs.team_actor_prs[k])}}`)
        .join('\n\n')

      return {{
        ...open_prs,
        team_actor_prs_content
      }};
    }}
  ]], {}, { delimieters = "{}" })),
  s("results-of-previous-task-full", fmt([[
  import { execution } from '@dynatrace-sdk/automation-utils';
  export default async function ({ execution_id }) {
    const executionContext = await execution(execution_id);
    const [task_name] = await executionContext.result("[task_name]");
  }
  ]], { task_name = i(1, 'name_of_prev_task') }, { delimiters = "[]", repeat_duplicates = true })),
  s("results-of-previous-task", fmt([[
    const executionContext = await execution(execution_id);
    const [task_name] = await executionContext.result("[task_name]");
  ]], { task_name = i(1, 'name_of_task') }, { delimiters = "[]", repeat_duplicates = true })),
  s("results-of-previous-task-terse", fmt([[
    export default async function ({ execution_id }) {
      return (await (await execution(execution_id))
          .result("augment_project_with_open_prs"))
          .projects
          .map(bitbucketPRsToDomainPRs)
    }
  ]], {}, { delimiters = "[]" })),
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
    import { execution } from "@dynatrace-sdk/automation-utils";
    export default async function ({ execution_id }) {
      const exec_obj = await execution(execution_id)
      const event = exec_obj.params.event
      event.get("some.key", "defaultValue")
    }
  ]], {}, { delimiters = "<>" })),
  s("format-timestamp", fmt([[
    export default async function () {

      /**
        *  @returns - string formatted as YYYY-mm-dd HH:MM:SS+0100
        */
      const format_date = (dateTime: Date) => {
        const pad = (char) => (total_chars) => (value) => value.toString().padStart(total_chars, char);
        const pad_zero = pad('0')(2)
        return `${dateTime.getFullYear()}-${pad_zero(dateTime.getMonth()+1)}-${pad_zero(dateTime.getDate())} ${pad_zero(dateTime.getHours())}:${pad_zero(dateTime.getMinutes())}:${pad_zero(dateTime.getSeconds())}+0100`
      }

      const zulu_to_cet = (zulu = new Date()) => new Date(zulu.setHours(zulu.getHours() + 1))
      const now = zulu_to_cet();

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
