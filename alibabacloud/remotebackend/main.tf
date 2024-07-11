module "oss-backend" {
  source                    = "terraform-alicloud-modules/remote-backend/alicloud"
  version                   = "1.2.0"
  create_backend_bucket     = true
  create_ots_lock_instance  = true
  create_ots_lock_table     = true
  backend_ots_lock_instance = "tf-oss-veri2a5e0"
  region                    = "ap-southeast-3"
  state_name                = "prod/terraform.tfstate"

  encrypt_state = true
}