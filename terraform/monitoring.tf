resource "datadog_monitor" "github_actions_failure_monitor" {
  name = "GitHub Actions Pipeline Failure"
  type = "log alert"
  tags = ["team:cs489-rpts"]

  message = "The {{log.attributes.ci.pipeline.name}} pipeline failed. Notifying @slack-datadog. Please investigate."
  query = "logs(\"service:github-actions status:error\").index(\"*\").rollup(\"count\").last(\"5m\") >= 1"

  monitor_thresholds {
    critical = "1"
  }

  enable_logs_sample = true
  
  priority = 2
}