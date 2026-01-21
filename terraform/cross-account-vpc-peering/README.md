Usage
```tf
module "cross_account_vpc_peering" {
  for_each = var.vpc_peering

  source = "./modules/cross-account-vpc-peering"

  requestor_vpc_id = module.vpc.vpc_id

  acceptor_account_id = each.value.account_id
  acceptor_aws_region = each.value.aws_region
  acceptor_vpc_id     = each.value.vpc_id
  acceptor_cidr_block = each.value.cidr
}
```
