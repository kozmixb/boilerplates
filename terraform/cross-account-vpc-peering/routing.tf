data "aws_route_tables" "requestor" {
  vpc_id = var.requestor_vpc_id
}

resource "aws_route" "requestor" {
  for_each = toset(data.aws_route_tables.requestor.ids)

  route_table_id            = each.value
  destination_cidr_block    = var.acceptor_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.requestor.id
}
