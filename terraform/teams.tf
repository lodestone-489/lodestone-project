resource "datadog_team" "rpts" {
  description = "The Release Pipeline Task Squad for the CS 489 project."
  handle      = "cs489-rpts"
  name        = "Release Pipeline Task Squad"
}

resource "datadog_team_membership" "shayn_rpts" {
  team_id = datadog_team.rpts.id
  user_id = datadog_user.shayn.id
  role    = "admin"
}

resource "datadog_team_membership" "switt_rpts" {
  team_id = datadog_team.rpts.id
  user_id = datadog_user.switt.id
  role    = "admin"
}
