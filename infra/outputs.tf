output "webapp_name" { value = azurerm_linux_web_app.web.name }
output "prod_url"    { value = "https://${azurerm_linux_web_app.web.default_hostname}" }
output "staging_url" { value = "https://${azurerm_linux_web_app_slot.staging.default_hostname}" }