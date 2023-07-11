resource "aws_lb" "loadbalancer" {
  name = var.project
  internal = false
  load_balancer_type = "application"
  security_groups = [ aws_security_group.asg.id ]
  subnets = local.public_subnets 
  lifecycle {
    ignore_changes = [
      subnets
    ]
  }
  ip_address_type = "ipv4"
  tags = local.tags
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.loadbalancer.arn
  port = 80
  protocol = "HTTP"
  default_action {
    type = "redirect"
    redirect {
      port = "443"
      protocol = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.loadbalancer.arn
  port = 443
  protocol = "HTTPS"
  ssl_policy = "ELBSecurityPolicy-2016-08"
  certificate_arn = data.aws_acm_certificate.acm.arn
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.frontend.arn
  }
}

resource "aws_lb_target_group" "frontend" {
  name = "${var.project}-frontend"
  port = 80
  protocol = "HTTP"
  vpc_id = data.aws_vpc.vpc.id
}

resource "aws_lb_target_group_attachment" "frontend" {
  target_group_arn = aws_lb_target_group.frontend.arn
  target_id = aws_instance.ec2["frontend"].id
  port = 80
}

resource "aws_alb_listener_rule" "mockserver-rule" {
  listener_arn = aws_lb_listener.https.arn
  priority = 100
  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.mockserver.arn
  }
  condition {
    host_header {
      values = [ "bc84mockserver.bootcamp64.tk" ]
    }
  }
}

resource "aws_lb_target_group" "mockserver" {
  name = "${var.project}-mockserver"
  port = 8080
  protocol = "HTTP"
  vpc_id = data.aws_vpc.vpc.id
}

resource "aws_lb_target_group_attachment" "mockserver" {
  target_group_arn = aws_lb_target_group.mockserver.arn
  port = 8080
  target_id = aws_instance.ec2["frontend"].id
}



# backend load balancer configuration
resource "aws_alb_listener_rule" "backend-rule" {
  listener_arn = aws_lb_listener.https.arn
  priority = 101
  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.backend.arn
  }
  condition {
    path_pattern {
      values = ["/api*"]
    }
  }
  condition {
    host_header {
      values = [ "bc84be.bootcamp64.tk" ]
    }
  }
}

resource "aws_lb_target_group" "backend" {
  name = "${var.project}-backend"
  port = 9000
  protocol = "HTTP"
  vpc_id = data.aws_vpc.vpc.id
  health_check {
    path = "/actuator/health"
  }
}

resource "aws_lb_target_group_attachment" "backend" {
  target_group_arn = aws_lb_target_group.backend.arn
  port = 9000
  target_id = aws_instance.ec2["backend"].id
}

resource "aws_alb_listener_rule" "backend-rule-eureka" {
  listener_arn = aws_lb_listener.https.arn
  priority = 102
  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.backend-eureka.arn
  }
  condition {
    host_header {
      values = [ "bc84be.bootcamp64.tk" ]
    }
  }
}

resource "aws_lb_target_group" "backend-eureka" {
  name = "${var.project}-backend-eureka"
  port = 8761
  protocol = "HTTP"
  vpc_id = data.aws_vpc.vpc.id
  health_check {
    path = "/actuator/health"
  }
}

resource "aws_lb_target_group_attachment" "backend-eureka" {
  target_group_arn = aws_lb_target_group.backend-eureka.arn
  port = 8761
  target_id = aws_instance.ec2["backend"].id
}

resource "aws_alb_listener_rule" "backend-rule-users" {
  listener_arn = aws_lb_listener.https.arn
  priority = 99
  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.backend-users.arn
  }
  condition {
    host_header {
      values = [ "bc84be.bootcamp64.tk" ]
    }
  }
  condition {
    path_pattern {
      values = [ "/api/users/token" ]
    }
  }
}

resource "aws_lb_target_group" "backend-users" {
  name = "${var.project}-backend-users"
  port = 9001
  protocol = "HTTP"
  vpc_id = data.aws_vpc.vpc.id
  health_check {
    path = "/actuator/health"
  }
}

resource "aws_lb_target_group_attachment" "backend-users" {
  target_group_arn = aws_lb_target_group.backend-users.arn
  port = 9001
  target_id = aws_instance.ec2["backend"].id
}