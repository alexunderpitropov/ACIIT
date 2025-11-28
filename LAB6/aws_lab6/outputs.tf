output "ec2_public_ip" {
  value = aws_instance.webserver.public_ip
}

output "bucket_name" {
  value = aws_s3_bucket.simple_bucket.bucket
}
