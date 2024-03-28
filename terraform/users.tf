resource "datadog_user" "shayn" {
  email = "s4adatia@uwaterloo.ca"

  roles = [data.datadog_role.ro_role.id]
}

resource "datadog_user" "switt" {
  email = "mswitt@uwaterloo.ca"

  roles = [data.datadog_role.ro_role.id]
}

resource "datadog_user" "grading_team" {
  email = "lodestone.temp@outlook.com"
  name = "Grading Team"

  roles = [data.datadog_role.ro_role.id]
}
