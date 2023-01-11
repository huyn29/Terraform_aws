 #!/bin/bash
sudo yum update -y
sudo yum install httpd -y
sudo service httpd start
sudo bash -c  "echo '<center><h1>I am huy</h1></center>' > /var/www/html/index.html"