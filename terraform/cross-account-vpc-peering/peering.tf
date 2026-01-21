resource "aws_vpc_peering_connection" "requestor" {
  vpc_id        = var.requestor_vpc_id
  peer_owner_id = var.acceptor_account_id
  peer_vpc_id   = var.acceptor_vpc_id
  peer_region   = var.acceptor_aws_region
  auto_accept   = false
  tags = {
    Name = "Requestor to Acceptor"
  }
}
