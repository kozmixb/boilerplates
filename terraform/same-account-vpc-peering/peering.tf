resource "aws_vpc_peering_connection" "peer" {
  peer_owner_id = var.aws_account_id
  peer_region   = var.aws_region
  vpc_id        = var.requestor_vpc_id
  peer_vpc_id   = var.acceptor_vpc_id
  auto_accept   = false
}

resource "aws_vpc_peering_connection_accepter" "peer" {
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
  auto_accept               = true
}
