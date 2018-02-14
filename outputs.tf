output "heroku_hostname" {
  value = "${heroku_app.kontena_master.heroku_hostname}"
}

output "config" {
  value = "${heroku_app.kontena_master.all_config_vars}"
}

output "id" {
  # Declare all resources here to make depends_id working correctly
  value = "${null_resource.provision_completed.id}-${heroku_addon.mongo.id}"
}
