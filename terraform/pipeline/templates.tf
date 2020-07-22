////////////////////////////////
// templates

data "template_file" "install_hab" {
  template = file("${path.module}/../templates/install-hab.sh")

  vars = {
    opts = var.hab_install_opts
  }
}

data "template_file" "audit_toml_linux_prod" {
  template = file("${path.module}/../templates/audit_linux.toml")

  vars = {
    automate_url   = var.automate_url
    automate_token = var.automate_token
    automate_user  = var.automate_user
    chef_env       = "production"
  }
}

data "template_file" "config_toml_linux_prod" {
  template = file("${path.module}/../templates/config_linux.toml")

  vars = {
    automate_url   = var.automate_url
    automate_token = var.automate_token
    automate_user  = var.automate_user
    chef_env       = "production"
  }
}

data "template_file" "audit_toml_linux_dev" {
  template = file("${path.module}/../templates/audit_linux.toml")

  vars = {
    automate_url   = var.automate_url
    automate_token = var.automate_token
    automate_user  = var.automate_user
    chef_env       = "development"
  }
}

data "template_file" "config_toml_linux_dev" {
  template = file("${path.module}/../templates/config_linux.toml")

  vars = {
    automate_url   = var.automate_url
    automate_token = var.automate_token
    automate_user  = var.automate_user
    chef_env       = "development"
  }
}


