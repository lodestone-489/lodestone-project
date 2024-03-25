resource "datadog_dashboard_list" "terraform_managed_dashboards" {
  name = "Terraform Managed Dashboards"

  dash_item {
    type = "custom_timeboard"
    dash_id = datadog_dashboard.github_actions_dashboard.id
  }
}

resource "datadog_dashboard" "github_actions_dashboard" {
  title       = "GitHub Actions Dashboard"
  description = "Dashboard for information on GitHub Actions pipelines. Created and managed by Terraform."
  tags = ["team:cs489-rpts"]

  layout_type = "ordered"
  notify_list = []
  reflow_type = "fixed"

  template_variable {
    name    = "pipeline_name"
    prefix  = "@ci.pipeline.name"
    available_values = ["Core - Build and Draft", "Core - Cargo Test", "Core - Clippy Check", "Core - Release Docker", "Dashboard - Build and Draft", "Dashboard - Build Frontend", "Dashboard - Check", "Delete old workflow runs", "Developer Workflow", "Pull Request Workflow", "Release Candidate Workflow", "Release Workflow", "Workspace - Check", "Dashboard - Test Frontend"]
    defaults = ["Core - Build and Draft", "Core - Cargo Test", "Core - Clippy Check", "Core - Release Docker", "Dashboard - Build and Draft", "Dashboard - Build Frontend", "Dashboard - Check", "Delete old workflow runs", "Developer Workflow", "Pull Request Workflow", "Release Candidate Workflow", "Release Workflow", "Workspace - Check", "Dashboard - Test Frontend"]
  }

  template_variable {
    name    = "branch_name"
    prefix  = "@git.branch"
    defaults = ["main"]
  }

  widget {
    group_definition {
      layout_type = "ordered"
      title       = "General"
      background_color = "vivid_green"

      widget {
        widget_layout {
          height = 2
          width = 6
          x = 0
          y = 0
        }

        timeseries_definition {
          title = "Pipeline executions"

          legend_columns = ["avg", "min", "max", "value", "sum"]
          legend_layout  = "auto"
          show_legend = false

          yaxis {
            include_zero = true
            label = ""
            max = "auto"
            min = "auto"
            scale = "linear"
          }
          
          request {
            display_type = "bars"

            formula {
              alias = "Pipeline executions"
              formula_expression = "query1"
            }

            on_right_yaxis = false

            query {
              event_query {
                name = "query1"

                compute {
                  aggregation = "count"
                }

                data_source = "ci_pipelines"

                group_by {
                  facet = "@ci.pipeline.name"
                  limit = 100
                  sort {
                    aggregation = "count"
                    order = "desc"
                  }
                }

                indexes = ["cipipeline"]

                search {
                  query = "ci_level:pipeline @ci.provider.name:${var.ci_provider_name} $pipeline_name $branch_name"
                }
              }
            }

            style {
              line_type = "solid"
              line_width = "normal"
              palette = "dog_classic"
            }
          }
        }
      }

      widget {
        widget_layout {
          height = 2
          width = 6
          x = 6
          y = 0
        }

        query_value_definition {
          title = "Pipeline overall success rate"
          title_align = "left"
          title_size = "16"

          custom_unit = "%"
          precision = 2

          request {
            conditional_formats {
              comparator = "<"
              palette = "white_on_red"
              value = 90
            }

            conditional_formats {
              comparator = ">="
              palette = "white_on_green"
              value = 90
            }

            formula {
              alias = "failure_rate"
              formula_expression = "100 - (query9 / query10 * 100)"
            }

            query {
              event_query {
                name = "query9"

                compute {
                  aggregation = "count"
                  interval = 86400000
                }

                data_source = "ci_pipelines"
                indexes = ["cipipeline"]

                search {
                  query = "ci_level:pipeline @ci.status:error @ci.provider.name:${var.ci_provider_name} $pipeline_name $branch_name"
                }
              }
            }

            query {
              event_query {
                name = "query10"

                compute {
                  aggregation = "count"
                  interval = 86400000
                }

                data_source = "ci_pipelines"
                indexes = ["cipipeline"]

                search {
                  query = "ci_level:pipeline @ci.provider.name:${var.ci_provider_name} $pipeline_name $branch_name"
                }
              }
            }
          }
        }
      }

      widget {
        widget_layout {
          height = 2
          width = 6
          x = 0
          y = 2
        }

        timeseries_definition {
          title = "Pipeline duration"

          legend_columns = ["avg", "min", "max", "value", "sum"]
          legend_layout  = "auto"
          show_legend = false

          yaxis {
            include_zero = true
            label = ""
            max = "auto"
            min = "auto"
            scale = "linear"
          }
          
          request {
            display_type = "line"

            formula {
              alias = "Median duration"
              formula_expression = "query1"
            }

            on_right_yaxis = false

            query {
              event_query {
                name = "query1"

                compute {
                  aggregation = "median"
                  metric = "@duration"
                }

                data_source = "ci_pipelines"
                indexes = ["cipipeline"]

                search {
                  query = "ci_level:pipeline @ci.provider.name:${var.ci_provider_name} $pipeline_name $branch_name"
                }
              }
            }

            style {
              line_type = "solid"
              line_width = "normal"
              palette = "dog_classic"
            }
          }

          request {
            display_type = "line"

            formula {
              alias = "p95 duration"
              formula_expression = "query0"
            }

            on_right_yaxis = false

            query {
              event_query {
                name = "query0"

                compute {
                  aggregation = "pc95"
                  metric = "@duration"
                }

                data_source = "ci_pipelines"
                indexes = ["*"]

                search {
                  query = "ci_level:pipeline @ci.provider.name:${var.ci_provider_name} $pipeline_name $branch_name"
                }
              }
            }

            style {
              line_type = "solid"
              line_width = "normal"
              palette = "warm"
            }
          }
        }
      }

      widget {
        widget_layout {
          height = 5
          width = 12
          x = 0
          y = 4
        }

        query_table_definition {
          title = "Top slowest pipelines"

          request {
            formula {
              cell_display_mode = "bar"
              formula_expression = "query2"
              
              limit {
                count = 10
                order = "desc"
              }
            }

            formula {
              cell_display_mode = "bar"
              formula_expression = "query3"
            }

            formula {
              cell_display_mode = "bar"
              formula_expression = "query4"
            }

            query {
              event_query {
                name = "query2"

                compute {
                  aggregation = "median"
                  metric = "@duration"
                }

                data_source = "ci_pipelines"

                group_by {
                  facet = "@ci.pipeline.name"
                  limit = 10

                  sort {
                    aggregation = "median"
                    metric = "@duration"
                    order = "desc"
                  }
                }

                indexes = ["cipipeline"]

                search {
                  query = "ci_level:pipeline @ci.status:success ci_partial_retry:false @ci.provider.name:${var.ci_provider_name} $pipeline_name $branch_name"
                }
              }
            }

            query {
              event_query {
                name = "query3"

                compute {
                  aggregation = "pc95"
                  metric = "@duration"
                }

                data_source = "ci_pipelines"

                group_by {
                  facet = "@ci.pipeline.name"
                  limit = 10

                  sort {
                    aggregation = "median"
                    metric = "@duration"
                    order = "desc"
                  }
                }

                indexes = ["cipipeline"]

                search {
                  query = "ci_level:pipeline @ci.status:success ci_partial_retry:false @ci.provider.name:${var.ci_provider_name} $pipeline_name $branch_name"
                }
              }
            }

            query {
              event_query {
                name = "query4"

                compute {
                  aggregation = "sum"
                  metric = "@duration"
                }

                data_source = "ci_pipelines"

                group_by {
                  facet = "@ci.pipeline.name"
                  limit = 10

                  sort {
                    aggregation = "median"
                    metric = "@duration"
                    order = "desc"
                  }
                }

                indexes = ["cipipeline"]

                search {
                  query = "ci_level:pipeline @ci.status:success ci_partial_retry:false @ci.provider.name:${var.ci_provider_name} $pipeline_name $branch_name"
                }
              }
            }
          }
        }
      }
    }
  }

  widget {
    group_definition {
      title = "Failures"
      layout_type = "ordered"
      background_color = "vivid_pink"

      widget {
        widget_layout {
          height = 2
          width = 12
          x = 0
          y = 12
        }

        timeseries_definition {
          title = "Pipeline failure rate"
          title_align = "left"
          title_size = "16"

          legend_columns = ["avg", "min", "max", "value", "sum"]
          legend_layout  = "auto"
          show_legend = true

          yaxis {
            include_zero = true
            label = ""
            max = "auto"
            min = "auto"
            scale = "linear"
          }
          
          request {
            display_type = "line"

            formula {
              alias = "Failure rate"
              formula_expression = "query1 / (query2 + query1) * 100"
            }

            on_right_yaxis = false

            query {
              event_query {
                name = "query1"

                compute {
                  aggregation = "count"
                }

                data_source = "ci_pipelines"
                indexes = ["*"]

                search {
                  query = "ci_level:pipeline @ci.status:error @ci.provider.name:${var.ci_provider_name} $pipeline_name $branch_name"
                }
              }
            }

            query {
              event_query {
                name = "query2"

                compute {
                  aggregation = "count"
                }

                data_source = "ci_pipelines"
                indexes = ["*"]

                search {
                  query = "ci_level:pipeline @ci.status:success @ci.provider.name:${var.ci_provider_name} $pipeline_name $branch_name"
                }
              }
            }

            style {
              line_type = "solid"
              line_width = "normal"
              palette = "warm"
            }
          }
        }
      }

      widget {
        widget_layout {
          height = 2
          width = 6
          x = 0
          y = 14
        }

        timeseries_definition {
          title = "Pipeline failures"

          legend_columns = ["avg", "min", "max", "value", "sum"]
          legend_layout  = "auto"
          show_legend = false

          yaxis {
            include_zero = true
            label = ""
            max = "auto"
            min = "auto"
            scale = "linear"
          }
          
          request {
            display_type = "bars"

            formula {
              alias = "Pipeline failures"
              formula_expression = "query1"
            }

            on_right_yaxis = false

            query {
              event_query {
                name = "query1"

                compute {
                  aggregation = "count"
                }

                data_source = "ci_pipelines"

                group_by {
                  facet = "@ci.pipeline.name"
                  limit = 100
                  sort {
                    aggregation = "count"
                    order = "desc"
                  }
                }

                indexes = ["cipipeline"]

                search {
                  query = "ci_level:pipeline @ci.provider.name:${var.ci_provider_name} $pipeline_name $branch_name @ci.status:error"
                }
              }
            }

            style {
              line_type = "solid"
              line_width = "normal"
              palette = "red"
            }
          }
        }
      }

      widget {
        widget_layout {
          height = 2
          width = 6
          x = 6
          y = 14
        }

        timeseries_definition {
          title = "Failed pipelines accumulated duration"

          legend_columns = ["avg", "min", "max", "value", "sum"]
          legend_layout  = "auto"
          show_legend = false

          yaxis {
            include_zero = true
            label = ""
            max = "auto"
            min = "auto"
            scale = "linear"
          }
          
          request {
            display_type = "area"

            formula {
              alias = "Failed pipeline accumulated duration"
              formula_expression = "query1"
            }

            on_right_yaxis = false

            query {
              event_query {
                name = "query1"

                compute {
                  aggregation = "sum"
                  metric = "@duration"
                }

                data_source = "ci_pipelines"

                group_by {
                  facet = "@ci.pipeline.name"
                  limit = 100
                  sort {
                    aggregation = "sum"
                    metric = "@duration"
                    order = "desc"
                  }
                }

                indexes = ["cipipeline"]

                search {
                  query = "ci_level:pipeline @ci.provider.name:${var.ci_provider_name} $pipeline_name $branch_name @ci.status:error"
                }
              }
            }

            style {
              line_type = "solid"
              line_width = "normal"
              palette = "red"
            }
          }
        }
      }

      widget {
        widget_layout {
          height = 5
          width = 12
          x = 0
          y = 16
        }

        query_table_definition {
          title = "Top failed pipelines"

          request {
            formula {
              cell_display_mode = "bar"
              formula_expression = "query1"

              conditional_formats {
                comparator = ">"
                palette = "red_on_white"
                value = 0
              }
              
              limit {
                count = 10
                order = "desc"
              }
            }

            formula {
              cell_display_mode = "bar"
              formula_expression = "query2"

              conditional_formats {
                comparator = ">"
                palette = "red_on_white"
                value = 0
              }
            }

            formula {
              cell_display_mode = "bar"
              formula_expression = "query3"

              conditional_formats {
                comparator = ">"
                palette = "red_on_white"
                value = 0
              }
            }

            formula {
              cell_display_mode = "bar"
              formula_expression = "query4"

              conditional_formats {
                comparator = ">"
                palette = "red_on_white"
                value = 0
              }
            }

            query {
              event_query {
                name = "query1"

                compute {
                  aggregation = "count"
                }

                data_source = "ci_pipelines"

                group_by {
                  facet = "@ci.pipeline.name"
                  limit = 10

                  sort {
                    aggregation = "count"
                    order = "desc"
                  }
                }

                indexes = ["cipipeline"]

                search {
                  query = "ci_level:pipeline @ci.provider.name:${var.ci_provider_name} $pipeline_name $branch_name @ci.status:error ci_partial_retry:false"
                }
              }
            }

            query {
              event_query {
                name = "query2"

                compute {
                  aggregation = "median"
                  metric = "@duration"
                }

                data_source = "ci_pipelines"

                group_by {
                  facet = "@ci.pipeline.name"
                  limit = 10

                  sort {
                    aggregation = "count"
                    order = "desc"
                  }
                }

                indexes = ["cipipeline"]

                search {
                  query = "ci_level:pipeline @ci.provider.name:${var.ci_provider_name} $pipeline_name $branch_name @ci.status:error ci_partial_retry:false"
                }
              }
            }

            query {
              event_query {
                name = "query3"

                compute {
                  aggregation = "pc95"
                  metric = "@duration"
                }

                data_source = "ci_pipelines"

                group_by {
                  facet = "@ci.pipeline.name"
                  limit = 10

                  sort {
                    aggregation = "count"
                    order = "desc"
                  }
                }

                indexes = ["cipipeline"]

                search {
                  query = "ci_level:pipeline @ci.provider.name:${var.ci_provider_name} $pipeline_name $branch_name @ci.status:error ci_partial_retry:false"
                }
              }
            }

            query {
              event_query {
                name = "query4"

                compute {
                  aggregation = "sum"
                  metric = "@duration"
                }

                data_source = "ci_pipelines"

                group_by {
                  facet = "@ci.pipeline.name"
                  limit = 10

                  sort {
                    aggregation = "count"
                    order = "desc"
                  }
                }

                indexes = ["cipipeline"]

                search {
                  query = "ci_level:pipeline @ci.provider.name:${var.ci_provider_name} $pipeline_name $branch_name @ci.status:error ci_partial_retry:false"
                }
              }
            }
          }
        }
      }
    }
  }

  widget {
    group_definition {
      title = "Queue Times"
      layout_type = "ordered"
      background_color = "vivid_orange"

      widget {
        widget_layout {
          height = 2
          width = 6
          x = 0
          y = 21
        }

        timeseries_definition {
          title = "Accumulated queue time per pipeline"
          title_align = "left"
          title_size = "16"

          legend_columns = ["avg", "min", "max", "value", "sum"]
          legend_layout  = "auto"
          show_legend = false

          yaxis {
            include_zero = true
            label = ""
            max = "auto"
            min = "auto"
            scale = "linear"
          }
          
          request {
            display_type = "area"

            formula {
              alias = "Accumulated queue time"
              formula_expression = "query1"
            }

            on_right_yaxis = false

            query {
              event_query {
                name = "query1"

                compute {
                  aggregation = "sum"
                  metric = "@ci.queue_time"
                }

                data_source = "ci_pipelines"

                group_by {
                  facet = "@ci.pipeline.name"
                  limit = 100
                  sort {
                    aggregation = "sum"
                    metric = "@ci.queue_time"
                    order = "desc"
                  }
                }

                indexes = ["cipipeline"]

                search {
                  query = "@ci.provider.name:${var.ci_provider_name} $pipeline_name $branch_name"
                }
              }
            }

            style {
              line_type = "solid"
              line_width = "normal"
              palette = "orange"
            }
          }
        }
      }

      widget {
        widget_layout {
          height = 5
          width = 12
          x = 0
          y = 23
        }

        query_table_definition {
          title = "Top pipelines by queue time"
          title_align = "left"
          title_size = "16"
          has_search_bar = "never"

          request {
            formula {
              cell_display_mode = "bar"
              formula_expression = "query1"
              
              limit {
                count = 10
                order = "desc"
              }
            }

            formula {
              cell_display_mode = "bar"
              formula_expression = "query2"
            }

            formula {
              cell_display_mode = "bar"
              formula_expression = "query3"
            }

            query {
              event_query {
                name = "query1"

                compute {
                  aggregation = "median"
                  metric = "@ci.queue_time"
                }

                data_source = "ci_pipelines"

                group_by {
                  facet = "@ci.pipeline.name"
                  limit = 10

                  sort {
                    aggregation = "median"
                    metric = "@ci.queue_time"
                    order = "desc"
                  }
                }

                indexes = ["cipipeline"]

                search {
                  query = "@ci.provider.name:${var.ci_provider_name} $pipeline_name $branch_name"
                }
              }
            }

            query {
              event_query {
                name = "query2"

                compute {
                  aggregation = "pc95"
                  metric = "@ci.queue_time"
                }

                data_source = "ci_pipelines"

                group_by {
                  facet = "@ci.pipeline.name"
                  limit = 10

                  sort {
                    aggregation = "median"
                    metric = "@ci.queue_time"
                    order = "desc"
                  }
                }

                indexes = ["cipipeline"]

                search {
                  query = "@ci.provider.name:${var.ci_provider_name} $pipeline_name $branch_name"
                }
              }
            }

            query {
              event_query {
                name = "query3"

                compute {
                  aggregation = "sum"
                  metric = "@ci.queue_time"
                }

                data_source = "ci_pipelines"

                group_by {
                  facet = "@ci.pipeline.name"
                  limit = 10

                  sort {
                    aggregation = "median"
                    metric = "@ci.queue_time"
                    order = "desc"
                  }
                }

                indexes = ["cipipeline"]

                search {
                  query = "@ci.provider.name:${var.ci_provider_name} $pipeline_name $branch_name"
                }
              }
            }
          }
        }
      }
    }
  }
}
