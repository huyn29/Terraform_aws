# Create a application load balancer
resource "aws_lb" "huyn_lb" {
  name               = var.lb_name
  internal           = false
  load_balancer_type = var.load_balancer_type
  security_groups    = var.security_groups #[aws_security_group.sg_lb.id]
  subnets            = var.subnets         #[for subnet in aws_subnet.public : subnet.id]

  enable_deletion_protection = false
  tags = {
    "Name" = "${var.lb_name}"
  }
}
# Create target group
resource "aws_lb_target_group" "lb_target_group" {
  name        = "tg-${var.lb_name}"
  port        = 80
  protocol    = "HTTP"
  target_type = var.lb_target_type
  vpc_id      = var.vpc_id
  depends_on  = [aws_lb.huyn_lb]
  tags = {
    "Name" = "tg-${var.lb_name}"
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

# # create a listener on port 80 with redirect action
# resource "aws_lb_listener" "lb_http_listener" {
#   load_balancer_arn = aws_lb.huyn_lb.arn
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
# create a listener on port 80 with forward action
resource "aws_lb_listener" "huyn_lb" {
  load_balancer_arn = aws_lb.huyn_lb.arn
  port              = 80
  protocol          = "HTTP"
  #certificate_arn   = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"
  #alpn_policy       = "HTTP2Preferred"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb_target_group.arn
  }
}

# resource "aws_lb_target_group_attachment" "lb_group_attachment" {

#   target_group_arn = aws_lb_target_group.lb_target_group.arn
#   target_id        = var.instance_id
#   port             = 80
# }
