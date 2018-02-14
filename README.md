# terraform-kontena-heroku-master

Setups a Kontena master in Heroku with Docker push. Requires `kontena` and `heroku` CLIs.

Additionally you need to run MongoDB's `repairDatabase` to compact the size every now and then (heroku scheduler can not be automated with Terraform) like this:

    $ heroku addons:create scheduler:standard --wait -a APP
    $ heroku addons:open scheduler -a APP

And create a task with:

    ruby -r ./app/boot.rb -e "puts Mongoid.default_client.command(repairDatabase: 1).documents.inspect"


## Usage

    module "heroku" {
      source  = "matti/heroku-master/kontena"

      app_name = "myown-kontena"
    }

or

    $ TF_VAR_app_name=myown-kontena terraform apply -auto-approve

    random_string.initial_admin_code: Creating...
      length:  "" => "32"
      lower:   "" => "true"
      number:  "" => "true"
      result:  "" => "<computed>"
      special: "" => "false"
      upper:   "" => "true"
    random_string.vault_iv: Creating...
      length:  "" => "64"
      lower:   "" => "true"
      number:  "" => "true"
      result:  "" => "<computed>"
      special: "" => "true"
      upper:   "" => "true"
    random_string.vault_key: Creating...
      length:  "" => "64"
      lower:   "" => "true"
      number:  "" => "true"
      result:  "" => "<computed>"
      special: "" => "true"
      upper:   "" => "true"
    random_string.vault_iv: Creation complete after 0s (ID: @BTNy}@ZcX}rhC@RhLa(=M%wxm=T=LgzALDM=nsr@As>gy8<7eRUZw2jKdLaDAky)
    random_string.initial_admin_code: Creation complete after 0s (ID: GgTxxzMlE8GNc27NlmmCzPld7xnAghCh)
    random_string.vault_key: Creation complete after 0s (ID: yZ<J2eugF)QCrcwHGVP3urwD]pj%jpwzV*J@{me[1<aZ!Qn>g}Fsn@V9D=etNRZj)
    heroku_app.kontena_master: Creating...
      all_config_vars.%:                         "" => "<computed>"
      config_vars.#:                             "" => "1"
      config_vars.0.%:                           "" => "9"
      config_vars.0.ACME_ENDPOINT:               "" => "https://acme-v01.api.letsencrypt.org/"
      config_vars.0.CONTAINER_LOGS_CAPPED_SIZE:  "" => "10"
      config_vars.0.CONTAINER_STATS_CAPPED_SIZE: "" => "10"
      config_vars.0.EVENT_LOGS_CAPPED_SIZE:      "" => "1"
      config_vars.0.INITIAL_ADMIN_CODE:          "" => "GgTxxzMlE8GNc27NlmmCzPld7xnAghCh"
      config_vars.0.MAX_THREADS:                 "" => "4"
      config_vars.0.VAULT_IV:                    "" => "@BTNy}@ZcX}rhC@RhLa(=M%wxm=T=LgzALDM=nsr@As>gy8<7eRUZw2jKdLaDAky"
      config_vars.0.VAULT_KEY:                   "" => "yZ<J2eugF)QCrcwHGVP3urwD]pj%jpwzV*J@{me[1<aZ!Qn>g}Fsn@V9D=etNRZj"
      config_vars.0.WEB_CONCURRENCY:             "" => "1"
      git_url:                                   "" => "<computed>"
      heroku_hostname:                           "" => "<computed>"
      name:                                      "" => "myown-kontena"
      organization.#:                            "" => "1"
      organization.0.personal:                   "" => "true"
      region:                                    "" => "us"
      stack:                                     "" => "<computed>"
      web_url:                                   "" => "<computed>"
    heroku_app.kontena_master: Creation complete after 1s (ID: myown-kontena)
    heroku_addon.mongo: Creating...
      app:           "" => "myown-kontena"
      config_vars.#: "" => "<computed>"
      name:          "" => "<computed>"
      plan:          "" => "mongolab:sandbox"
      provider_id:   "" => "<computed>"
    null_resource.master_deploy: Creating...
      triggers.%:                      "" => "1"
      triggers.kontena_master_version: "" => "latest"
    null_resource.master_deploy: Provisioning with 'local-exec'...
    null_resource.master_deploy (local-exec): Executing: ["/bin/sh" "-c" "heroku plugins:install --force heroku-container-registry"]
    null_resource.master_deploy (local-exec): Installing plugin heroku-container-registry...
    null_resource.master_deploy (local-exec): Installing heroku-container-registry@latest...
    null_resource.master_deploy (local-exec):  done
    null_resource.master_deploy: Provisioning with 'local-exec'...
    null_resource.master_deploy (local-exec): Executing: ["/bin/sh" "-c" "heroku container:login"]
    heroku_addon.mongo: Creation complete after 3s (ID: a4e22c83-0ad4-4fa1-8552-4ab89f89cbb9)
    null_resource.master_deploy (local-exec): Login Succeeded
    null_resource.master_deploy: Provisioning with 'local-exec'...
    null_resource.master_deploy (local-exec): Executing: ["/bin/sh" "-c" "docker pull kontena/server:latest"]
    null_resource.master_deploy (local-exec): latest: Pulling from kontena/server
    null_resource.master_deploy (local-exec): Digest: sha256:5c21c993441def1df8d35a87b1b2fa131a8cfdf22441823e52633c1cd0b44058
    null_resource.master_deploy (local-exec): Status: Image is up to date for kontena/server:latest
    null_resource.master_deploy: Provisioning with 'local-exec'...
    null_resource.master_deploy (local-exec): Executing: ["/bin/sh" "-c" "docker tag kontena/server:latest registry.heroku.com/myown-kontena/web"]
    null_resource.master_deploy: Provisioning with 'local-exec'...
    null_resource.master_deploy (local-exec): Executing: ["/bin/sh" "-c" "docker push registry.heroku.com/myown-kontena/web"]
    null_resource.master_deploy (local-exec): The push refers to repository [registry.heroku.com/myown-kontena/web]
    null_resource.master_deploy (local-exec): 627fcf92b30d: Preparing
    null_resource.master_deploy (local-exec): 804def2ac248: Preparing
    null_resource.master_deploy (local-exec): ed2231c636cf: Preparing
    null_resource.master_deploy (local-exec): 9c9155fa40e8: Preparing
    null_resource.master_deploy (local-exec): 6dfaec39e726: Preparing
    null_resource.master_deploy: Still creating... (10s elapsed)
    null_resource.master_deploy (local-exec): ed2231c636cf: Pushed
    null_resource.master_deploy (local-exec): 627fcf92b30d: Pushed
    null_resource.master_deploy (local-exec): 6dfaec39e726: Pushed
    null_resource.master_deploy (local-exec): 9c9155fa40e8: Pushed
    null_resource.master_deploy (local-exec): 804def2ac248: Pushed
    null_resource.master_deploy: Still creating... (20s elapsed)
    null_resource.master_deploy (local-exec): latest: digest: sha256:5c21c993441def1df8d35a87b1b2fa131a8cfdf22441823e52633c1cd0b44058 size: 1369
    null_resource.master_deploy: Creation complete after 24s (ID: 3415599153619877678)
    module.master_is_up.data.external.http: Refreshing state...
    null_resource.kontena_login_with_initial_admin_code: Creating...
    null_resource.cap_host_node_stats: Creating...
    null_resource.cap_host_node_stats: Provisioning with 'local-exec'...
    null_resource.kontena_login_with_initial_admin_code: Provisioning with 'local-exec'...
    null_resource.cap_host_node_stats (local-exec): Executing: ["/bin/sh" "-c" "heroku run -a myown-kontena -- ruby -r./app/boot.rb -e 'HostNodeStat.collection.client.command(convertToCapped: HostNodeStat.collection.name, capped: true, size: 10.megabytes)'"]
    null_resource.kontena_login_with_initial_admin_code (local-exec): Executing: ["/bin/sh" "-c" "kontena master login --name heroku-master --code GgTxxzMlE8GNc27NlmmCzPld7xnAghCh https://myown-kontena.herokuapp.com"]
    null_resource.cap_host_node_stats (local-exec): Running ruby -r./app/boot.rb -e "HostNodeStat.collection.client.command(convertToCapped: HostNodeStat.collection.name, capped: true, size: 10.megabytes)" on myown-kontena...

    null_resource.cap_host_node_stats (local-exec):  starting, run.1519 (Free)
    null_resource.cap_host_node_stats (local-exec): Running ruby -r./app/boot.rb -e "HostNodeStat.collection.client.command(convertToCapped: HostNodeStat.collection.name, capped: true, size: 10.megabytes)" on myown-kontena...

    null_resource.kontena_login_with_initial_admin_code (local-exec): Kontena Master heroku-master doesn't have any grids yet. Create one now using 'kontena grid create' command

    null_resource.cap_host_node_stats (local-exec):  connecting, run.1519 (Free)
    null_resource.kontena_login_with_initial_admin_code: Creation complete after 2s (ID: 2658611875445980146)
    null_resource.cap_host_node_stats (local-exec): Running ruby -r./app/boot.rb -e "HostNodeStat.collection.client.command(convertToCapped: HostNodeStat.collection.name, capped: true, size: 10.megabytes)" on myown-kontena...
    null_resource.cap_host_node_stats (local-exec):  up, run.1519 (Free)
    null_resource.cap_host_node_stats: Still creating... (10s elapsed)
    null_resource.cap_host_node_stats (local-exec): /app/app/models/grid_service.rb:44: warning: constant ::Fixnum is deprecated
    null_resource.cap_host_node_stats: Creation complete after 18s (ID: 7825866091475074931)

    Apply complete! Resources: 8 added, 0 changed, 0 destroyed.

    Outputs:

    config = {
      ACME_ENDPOINT = https://acme-v01.api.letsencrypt.org/
      CONTAINER_LOGS_CAPPED_SIZE = 10
      CONTAINER_STATS_CAPPED_SIZE = 10
      EVENT_LOGS_CAPPED_SIZE = 1
      INITIAL_ADMIN_CODE = GgTxxzMlE8GNc27NlmmCzPld7xnAghCh
      MAX_THREADS = 4
      VAULT_IV = @BTNy}@ZcX}rhC@RhLa(=M%wxm=T=LgzALDM=nsr@As>gy8<7eRUZw2jKdLaDAky
      VAULT_KEY = yZ<J2eugF)QCrcwHGVP3urwD]pj%jpwzV*J@{me[1<aZ!Qn>g}Fsn@V9D=etNRZj
      WEB_CONCURRENCY = 1
    }
    heroku_hostname = myown-kontena.herokuapp.com
