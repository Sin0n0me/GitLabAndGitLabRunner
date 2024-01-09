
cd SelfSignedCertificate
sudo docker compose build
sudo docker compose up
sudo docker exec gitlab gitlab-ctl restart
sudo docker restart gitlab
sudo docker exec gitlab /opt/gitlab/embedded/bin/openssl x509 -in /etc/gitlab/ssl/gitlab_sin0n0me_certificate.crt -text -noout

