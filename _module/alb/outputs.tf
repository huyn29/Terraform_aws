output "lb_target_group_arn" {
  value = aws_lb_target_group.lb_target_group.arn
}
output "lb_dns_name" {
  value = aws_lb.huyn_lb.dns_name
}
output "lb_zone_id" {
  value = aws_lb.huyn_lb.zone_id
}