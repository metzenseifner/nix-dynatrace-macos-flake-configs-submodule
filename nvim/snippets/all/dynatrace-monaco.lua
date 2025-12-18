return {
  s("vzx38435-manifest-environment", fmt([[
    - name: vzx38435
      url:
        value: https://vzx38435.dev.apps.dynatracelabs.com
      auth:
        token:
          type: environment
          name: VZX38435_MONACO_ACCESS_TOKEN
        oAuth:
          clientId:
            type: environment
            name: OAUTH_CLIENT_ID
          clientSecret:
            type: environment
            name: OAUTH_CLIENT_SECRET
          tokenEndpoint: https://sso-dev.dynatracelabs.com/sso/oauth2/token
  ]], {}, {})),
  s("vzx38435-config-environment-override-workflow", fmt([[
    - environment: vzx38435
      override:
        skip: false
        parameters:
          tenant_v3_domain: vzx38435.dev.apps.dynatracelabs.com
          saas_environment: "Development"
          dashboard_url: 'https://gmg80500.dev.apps.dynatracelabs.com/ui/apps/dynatrace.classic.dashboards/#dashboard;gtf=l_24_HOURS;gf=5271232584583297178;id=1ac9a6ed-491b-3d8f-8a18-fea616acf29b'
          argocd_url: 'https://dtp-dev-csc.vcluster.dtp.cd.internal.dynatracelabs.com/applications/argocd/dtp-dev-csc-central-services-email-control'
          event:
            type: value
            value:
              entity_id: "CLOUD_APPLICATION-85D03FE5E897EFDB"
  ]], {}, {})),
  s("vzx38435-config-environment-override-connection", fmt([[
    - environment: vzx38435
      override:
        skip: false
  ]], {}, {})),
  s("delete-settings-2.0-connection-object", fmt([[
  # Given a connection object config in project dynatrace.email
  #  
  # configs:
  #   - id: &slackConnectionConfigId 'dynatrace.email.slack.connection.object'
  #     type:
  #       settings:
  #         schema: &slackConnectionSchemaId 'app:dynatrace.slack:connection'
  #         scope: 'tenant'
  #         originObjectId: ???
  #     config:
  #       name: '[Dtp-App][dynatrace.email]PrototypeSlackAutomation'   # max 50 chars
  #       template: slack-connection-object.json
  #       parameters:
  #         token:
  #           type: environment
  #           name: 'PROTOTYPESLACKAUTOMATION_TOKEN'

  delete:
    - project: dynatrace.email 
      id: "dynatrace.email.slack.connection.object"
      type: "app:dynatrace.slack:connection"
      scope: tenant
  ]], {}, {}))
}
