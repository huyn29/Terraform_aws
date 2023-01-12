# Create a application load balancer
resource "aws_lb" "this" {
  name               = "${var.project}-lb"
  internal           = false
  load_balancer_type = var.load_balancer_type #Application or Network
  security_groups    = var.security_groups
  subnets            = var.subnets

  enable_deletion_protection = false
  tags = {
    "Name" = "${var.project}-lb"
  }
}
# Create target group
resource "aws_lb_target_group" "this" {
  name        = "${var.project}-tg-lb"
  port        = 80
  protocol    = "HTTP"
  target_type = var.lb_target_type
  vpc_id      = var.vpc_id
  depends_on  = [aws_lb.this]
  tags = {
    "Name" = "${var.project}-tg-lb"
  }
  health_check {
    enabled             = true
    interval            = 300
    path                = "/"
    timeout             = 60
    matcher             = 200
    healthy_threshold   = 5
    unhealthy_threshold = 5
  }
  lifecycle {
    create_before_destroy = true
  }
}
# create a listener on port 80 with forward action
resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"
  #certificate_arn   = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"
  #alpn_policy       = "HTTP2Preferred"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}
# # create a listener on port 80 with redirect action
# resource "aws_lb_listener" "lb_http_listener" {
#   load_balancer_arn = aws_lb.this.arn
#   port = "80"
#   protocol = "HTTP"
#   default_action {
#     type = "redirect"
#     redirect {
#       port = 443
#       protocol = "HTTPS"
#       status_code = "HTTP_301"
#     }
#   }
# }
# resource "aws_lb_target_group_attachment" "lb_group_attachment" {
#   target_group_arn = aws_lb_target_group.lb_target_group.arn
#   target_id        = var.instance_id
#   port             = 80
# }
