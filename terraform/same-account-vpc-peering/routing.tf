resource "aws_route" "requestor_vpc_peering" {
  for_each = toset(var.requestor_routing_ids)

  route_table_id            = each.value
  destination_cidr_block    = var.acceptor_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
}

resource "aws_route" "acceptor_vpc_peering" {
  for_each = toset(var.acceptor_routing_ids)

  route_table_id            = each.value
  destination_cidr_block    = var.requestor_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
}
