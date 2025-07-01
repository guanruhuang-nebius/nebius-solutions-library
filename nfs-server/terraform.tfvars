parent_id      = "project-e00z6b02t8ddk96c49" # The project-id in this context
subnet_id      = "vpcsubnet-e00p701fa30cj5f7wq" # Use the command "nebius vpc v1alpha1 network list" to see the subnet id
region         = "eu-north1" # Project region
ssh_user_name  = "tux" # Username you want to use to connect to the nodes
ssh_public_keys = [
   "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDFvAtxdCulpmQCLvk8mB3wYvb2L617q6acH9B1cOwJKr0c2vWMqH1vbH+GHc4VDSo/fceb6zYJ5haejKvzDjvSIWXDWIvQQqvB4NDdd0ZrxPx4qg4dPYYIhFvcIEDeir6alpzLelKd5CA4OPaJi2l7NNfsq8pfb9zEYol4hfTIkgrB7Q7NEHpvozAPf55cWkgJ+sK7H8ck4wCBJFYszjWxX3qjNPd2ZJ9K/o5VsrqBJwBcaL9CGvFen4QsXImQT+qKGuLqPCy9ycbCaQdOwldmzUTc0kygwbDVtQ9P6G30IT94vcRQefmERW2TD9IYDY89+7jD4k6o9zgqtlcJP8W8lmYCnmICWoSSYuZMXr86QehBZmZlbtSGacuugJirWb5kIGkihNlSXV5WKKXHubsUwO0Kbli2BCvh0SE5jpoBYM9r68+lxnnZSgR3PBL8d4t2RyWtAo+B6ydx4VI6roKhRpBUiQkjnWzAysWOdLOedk/L7ztSGLuSCte3rqiBNwU= tux@yoga", # First user's public key
#   "ssh-rsa AAAA..."  # Second user's public key
]
nfs_ip_range = "192.168.0.0/16"
disk_type = "NETWORK_SSD"
number_raid_disks = 8
nfs_size = 1200 * 1024 * 1024 * 1024
cpu_nodes_preset = "128vcpu-512gb"
