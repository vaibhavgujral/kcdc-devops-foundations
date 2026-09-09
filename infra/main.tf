resource "azurerm_resource_group" "app" {
  name     = "rg-quoteboard-${var.suffix}"
  location = var.location
}

resource "azurerm_log_analytics_workspace" "logs" {
  name                = "log-quoteboard-${var.suffix}"
  resource_group_name = azurerm_resource_group.app.name
  location            = var.location
  retention_in_days   = 30
}

resource "azurerm_application_insights" "ai" {
  name                = "appi-quoteboard-${var.suffix}"
  resource_group_name = azurerm_resource_group.app.name
  location            = var.location
  workspace_id        = azurerm_log_analytics_workspace.logs.id
  application_type    = "web"
}

# S1 is the cheapest tier that supports deployment slots (needed for blue/green in Lab 4)
resource "azurerm_service_plan" "plan" {
  name                = "asp-quoteboard-${var.suffix}"
  resource_group_name = azurerm_resource_group.app.name
  location            = var.location
  os_type             = "Linux"
  sku_name            = "S1"
}

resource "azurerm_linux_web_app" "web" {
  name                = "app-quoteboard-${var.suffix}"
  resource_group_name = azurerm_resource_group.app.name
  location            = var.location
  service_plan_id     = azurerm_service_plan.plan.id

  site_config {
    application_stack { dotnet_version = "10.0" }
    health_check_path                 = "/health"
    health_check_eviction_time_in_min = 2   # required alongside health_check_path in azurerm 4.x
  }

  app_settings = {
    "APPLICATIONINSIGHTS_CONNECTION_STRING" = azurerm_application_insights.ai.connection_string
    "FEATURE_NEW_BANNER"                    = "false"
    "FAIL_RATE"                             = "0"
  }
}

resource "azurerm_linux_web_app_slot" "staging" {
  name           = "staging"
  app_service_id = azurerm_linux_web_app.web.id

  site_config {
    application_stack { dotnet_version = "10.0" }
    health_check_path                 = "/health"
    health_check_eviction_time_in_min = 2   # required alongside health_check_path in azurerm 4.x
  }

  app_settings = {
    "APPLICATIONINSIGHTS_CONNECTION_STRING" = azurerm_application_insights.ai.connection_string
    "FEATURE_NEW_BANNER"                    = "false"
    "FAIL_RATE"                             = "0"
  }
}

# Page the team when production throws 5xx errors
resource "azurerm_monitor_metric_alert" "http5xx" {
  name                = "alert-quoteboard-5xx-${var.suffix}"
  resource_group_name = azurerm_resource_group.app.name
  scopes              = [azurerm_linux_web_app.web.id]
  description         = "More than 5 server errors in 5 minutes"
  frequency           = "PT1M"
  window_size         = "PT5M"
  severity            = 1

  criteria {
    metric_namespace = "Microsoft.Web/sites"
    metric_name      = "Http5xx"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = 5
  }
}