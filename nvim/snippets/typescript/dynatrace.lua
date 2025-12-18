return {
  s("appfunction-dependency-injection-experiment", fmt([=[
/**
 * Composition Root
 *
 * Builds our App Function.
 *
 * Enables dependency injection for easy
 * substitution of dependencies, especially useful in tests.
 */
export const buildAppFunction =
  (fetchDataFn: typeof fetchHotfixResourcesFromGrail) =>
  (cacheDataFn: typeof cacheData) =>
  async (config: UpdateHotfixStateConfig): Promise<Array<HotfixResource>> => {
    const data = await fetchDataFn(makeDQLQueryForRecentHotfixData());
    await cacheDataFn(hotfixStateKey, config.cacheUntilTime, data);
    if (config.mode === 'cache-only') {
      return [[]];
    }
    return data;
  };

/**
 * App function entry point
 * See https://developer.dynatrace.com/develop/app-functions/
 *
 * This function caches the domain type HotfixEvent and does not expose the raw Grail return type.
 */
export const syncHotfixAppState = buildAppFunction(fetchHotfixResourcesFromGrail)(cacheData)(defaultHotfixCacheConfig);
  ]=], {}, {delimiters="[]"})),
  s("jest.mock-connections", fmt([=[
    const SettingsURL =
      // eslint-disable-next-line no-secrets/no-secrets
      '**/settings/objects/**';
    const SettingsResponse = `{
      "items": [[
        {
          "objectId": "settings2.0-id",
          "value": {
            "type": "cloud-token",
            "url": "https://meteor.atlassian.net",
            "user": "some-user@email.com",
            "token": "random-cloud-api-token-content"
          }
        }
      ]],
      "totalCount": 1,
      "pageSize": 100
    }`;
  ]=],{},{delimiters="[]"})),
  s("jest.mock-connection-types", fmt([[
    const BasicConnectionSchema = ConnectionBaseSettingsSchema.extend({
      type: z.literal(ConnectionAuthenticationTypeSchema.enum.basic),
      user: z.string().trim().nonempty(),
      password: z.string().trim().nonempty(),
    });
    
    /**
     * Additional field(s) that are specific to the authentication method type 'cloud-token'.
     */
    const CloudTokenConnectionSchema = ConnectionBaseSettingsSchema.extend({
      type: z.literal(ConnectionAuthenticationTypeSchema.enum['cloud-token']),
      user: z.string().trim().nonempty(),
      token: z.string().trim().nonempty(),
    });
    
    /**
     * Additional field(s) that are specific to the authentication method type 'pat' (personal access token).
     */
    const PersonalAccessTokenConnectionSchema = ConnectionBaseSettingsSchema.extend({
      type: z.literal(ConnectionAuthenticationTypeSchema.enum.pat),
      token: z.string().trim().nonempty(),
    });
    
    /**
     * Extendable connection fields with ConnectionBaseSettings and credentials depending on the connection type.
     */
    export const ConnectionSettingsSchema = z.discriminatedUnion('type', [
      BasicConnectionSchema,
      CloudTokenConnectionSchema,
      PersonalAccessTokenConnectionSchema,
    ]);
    export type ConnectionSettings = z.infer<<typeof ConnectionSettingsSchema>>;
  ]], {}, {delimiters="<>"})),

  s("jest.mock-connection", fmt([[
    export const MOCKED_CLOUD_CONNECTION_SETTINGS: ConnectionSettings = {
      type: 'cloud-token',
      url: 'https://meteor.atlassian.net',
      user: 'some-user@email.com',
      token: 'random-cloud-api-token-content',
    };
    export const MOCKED_SERVER_CONNECTION_SETTINGS: ConnectionSettings = {
      type: 'basic',
      user: 'user',
      url: 'https://meteor.atlassian.net',
      password: 'password',
    };

--------------------------------------------------------------------------------
--                             For most use cases                             --
--------------------------------------------------------------------------------

    jest.mock('../../shared/domain/get-connection-settings');
    const mockGetConnectionSettings = getConnectionSettings as jest.MockedFunction<typeof getConnectionSettings>;
    mockGetConnectionSettings.mockResolvedValue(MOCKED_CLOUD_CONNECTION_SETTINGS);


--------------------------------------------------------------------------------
--                    For more control over mocked module                     --
--------------------------------------------------------------------------------

    export function mockGetConnection() {
      return jest.fn().mockImplementation(async (_connectionId: string, callback: (values: unknown) => BaseConnection) => {
        const settingsObjectValues = {
          type: 'cloud-token',
          url: 'https://meteor.atlassian.net',
          user: 'some-user@email.com',
          token: 'random-cloud-api-token-content',
        };
        return callback(settingsObjectValues);
      });
    }

    jest.mock('@dynatrace/sdk-automation-labs/lib/actions', () => ({
      __esModule: true,
      ...jest.requireActual('@dynatrace/sdk-automation-labs/lib/actions'),
      getConnection: mockGetConnection(),
    }));
  ]], {}, { delimiters = "[]" })),
  s("app-function", fmt([[
import { handleApiResponseError, parseActionInput, parseApiResponse } from '@backend/error-handling';
import { userLogger } from '@dynatrace-sdk/automation-action-utils/actions';
import { z } from 'zod';

/**
 * The input schema of this action for typechecking; The input payload.
 */
const [ActionNameF]ActionInputPayloadSchema = z.object({
  connectionId: z.string(),

})

/**
 * The type of the output of this action: The output payload.
 */
type [ActionNameF]ActionOutputPayload = { [lowerCamelCaseActionNameF]: z.infer<typeof [ActionNameF]RequestSchema> };

/**
 * The structure of the request sent to the 3rd party target.
 */
const [ActionNameF]RequestSchema = z.object({

});

/**
 * The structure of the response of the 3rd party target.
 */
const [ActionNameF]ResponseSchema = z.object({

});

/**
 * The [ActionName] Action.
 */
export default async (rawPayload: unknown): Promise<[ActionNameF]ActionOutputPayload> => {
  const payload = parseActionInput([ActionNameF]ActionInputPayloadSchema, rawPayload);
  const connection = await getConnection(payload.connectionId);

  const response =  await fetchData().catch(handleApiResponseError('The [ActionName] Action failed to fetch data.'))
  return { [lowerCamelCaseActionNameF]: response }
}
  ]], {
    lowerCamelCaseActionNameF = f(function(values)
      local lowerCamelCase = values[1][1]:gsub("^%u", string.lower)
      return lowerCamelCase
    end, { 1 }),
    ActionNameF = f(function(values)
      return values[1][1]
    end, { 1 }),
    ActionName = i(1, "ActionName"), --can pass this to input of function node
  }, { allow_duplicates = true, delimiters = "[]" }))
}
