module "heroku_cli" {
  source  = "matti/cli-outputs/heroku"
  version = "0.0.1"
}

locals {
  heroku_email       = "${var.heroku_email == "" ? module.heroku_cli.auth_whoami : var.heroku_email}"
  heroku_api_key     = "${var.heroku_api_key == "" ? module.heroku_cli.auth_token: var.heroku_api_key}"
  initial_admin_code = "${var.initial_admin_code == "" ? random_string.initial_admin_code.result : var.initial_admin_code}"
}

provider "heroku" {
  email   = "${local.heroku_email}"
  api_key = "${local.heroku_api_key}"
}

resource "heroku_addon" "mongo" {
  app  = "${heroku_app.kontena_master.name}"
  plan = "${var.mongo_addon_plan}"
}

# TODO: https://github.com/kontena/kontena/issues/3247
resource "random_string" "vault_key" {
  length = 64
}

resource "random_string" "vault_iv" {
  length = 64
}

resource "random_string" "initial_admin_code" {
  length  = 32
  special = false
}

resource "heroku_app" "kontena_master" {
  name   = "${var.app_name}"
  region = "${var.region}"

  #stack
  #buildpacks
  config_vars {
    VAULT_KEY                   = "${random_string.vault_key.result}"
    VAULT_IV                    = "${random_string.vault_iv.result}"
    INITIAL_ADMIN_CODE          = "${local.initial_admin_code}"
    ACME_ENDPOINT               = "https://acme-v01.api.letsencrypt.org/"
    MAX_THREADS                 = "${var.max_threads}"
    WEB_CONCURRENCY             = "${var.web_concurrency}"
    CONTAINER_LOGS_CAPPED_SIZE  = "${var.container_logs_capped_size}"
    CONTAINER_STATS_CAPPED_SIZE = "${var.container_stats_capped_size}"
    EVENT_LOGS_CAPPED_SIZE      = "${var.events_logs_capped_size}"
  }

  #space
  organization {
    name     = "${var.heroku_organization}"
    personal = "${var.heroku_organization == "" ? true : false}"
  }
}

resource "null_resource" "master_deploy" {
  triggers {
    kontena_master_version = "${var.kontena_master_version}"
  }

  provisioner "local-exec" {
    command = "heroku plugins:install --force heroku-container-registry"
  }

  provisioner "local-exec" {
    command = "heroku container:login"
  }

  provisioner "local-exec" {
    command = "docker pull kontena/server:${var.kontena_master_version}"
  }

  provisioner "local-exec" {
    command = "docker tag kontena/server:${var.kontena_master_version} registry.heroku.com/${heroku_app.kontena_master.name}/web"
  }

  provisioner "local-exec" {
    command = "docker push registry.heroku.com/${heroku_app.kontena_master.name}/web"
  }
}

module "master_is_up" {
  source  = "matti/until/http"
  version = "0.0.2"

  uri = "${heroku_app.kontena_master.web_url}"

  code_must_equal   = "200"
  body_must_include = "Kontena Master"

  depends_id = "${null_resource.master_deploy.id}"
}

resource "null_resource" "cap_host_node_stats" {
  depends_on = ["module.master_is_up"]

  provisioner "local-exec" {
    command = "heroku run -a ${heroku_app.kontena_master.name} -- ruby -r./app/boot.rb -e 'HostNodeStat.collection.client.command(convertToCapped: HostNodeStat.collection.name, capped: true, size: 10.megabytes)'"
  }
}

resource "null_resource" "kontena_login_with_initial_admin_code" {
  depends_on = ["null_resource.cap_host_node_stats", "module.master_is_up"]

  provisioner "local-exec" {
    command = "kontena master login --name ${var.kontena_master_name} --code ${local.initial_admin_code} https://${heroku_app.kontena_master.heroku_hostname}"
  }

  provisioner "local-exec" {
    when       = "destroy"
    command    = "kontena master rm --force ${var.kontena_master_name}"
    on_failure = "continue"
  }
}

resource "null_resource" "provision_completed" {
  depends_on = ["null_resource.kontena_login_with_initial_admin_code"]
}
