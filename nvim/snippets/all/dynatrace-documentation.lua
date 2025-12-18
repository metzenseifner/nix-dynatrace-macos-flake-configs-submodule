return {
  s("harbor-terraform-project", fmt([[
  # production/cloudautomation.tf
  resource "harbor_project" "cloudautomation" {
    enable_content_trust   = false
    name                   = "cloudautomation"
    public                 = true
    registry_id            = 0
    storage_quota          = -1
    vulnerability_scanning = true
  }
  
  ### MEMBERS ###
  
  module  "cloudautomation_project_admin_members" {
    source = "../modules/project_members"
    project_id = harbor_project.cloudautomation.id
    role = local.base.harbor_roles.project_admin
    user_names = [ # User the LDAP sAMAccountName. Case-sensitive.
      # Team Captains and POs
      "jonathan.komar",
      "david.petroni",
      "heinz.burgerstaller",
      "joerg.poecher",
      "michael.bernard",
      "nico.riedmann",
      "sarah.eibensteiner",
      "christian.kreuzberger",
      "claudia.gschliesser",
      "david.laubreiter",
      "edin.salaka",
      "manuel.warum",
      "omar.amr",
      "wolfgang.schedl"
    ]
  }
  
  module "cloudautomation_developer_members" {
    source = "../modules/project_members"
    project_id = harbor_project.cloudautomation.id
    role = local.base.harbor_roles.developer
    ldap_group_names = [   # User the LDAP sAMAccountName. Case-sensitive.
      { cn: "WW_Cap-CloudAutomation_U", ou: "DevApps.Lab"}   # Include all CA Teams
    ]
  }
  
  
  ### RETENTION POLICY ###
  
  resource "harbor_retention_policy" "cloudautomation" {
    schedule = "5 22 15 * *"
    scope    = harbor_project.cloudautomation.id
  
    rule {
      always_retain          = false
      disabled               = false
      most_recently_pulled   = 0
      most_recently_pushed   = 0
      n_days_since_last_pull = 365
      n_days_since_last_push = 0
      repo_matching          = "**"
      tag_matching           = "**"
      untagged_artifacts     = false
    }
  
    rule {
      always_retain          = false
      disabled               = false
      most_recently_pulled   = 0
      most_recently_pushed   = 7
      n_days_since_last_pull = 0
      n_days_since_last_push = 0
      repo_matching          = "**"
      tag_matching           = "**"
      untagged_artifacts     = false
    }
  }
  ]], {}, {delimiters="<>"}))
}
