variable "parent_id" {
  type        = string
  description = "Id of the folder where the resources going to be created."
}

variable "subnet_id" {
  type        = string
  description = "ID of the subnet."
}

variable "disk_type" {
  type        = string
  default     = "NETWORK_SSD_IO_M3" # "NETWORK_SSD"
  description = "Type of NFS data disk."
}

variable "disk_block_size" {
  type        = number
  default     = 4096
  description = "Disk block size."
}

# STORAGE VM RESOURCES
variable "platform" {
  description = "VM platform."
  type        = string
  default     = "cpu-d3"
}

variable "preset" {
  description = "VM resources preset."
  type        = string
  default     = "16vcpu-64gb"
}

# SSH KEY
variable "ssh_public_keys" {
  type        = list(string)
  description = "List of SSH public keys allowed to access the NFS server."
  default     = []
}

variable "instance_name" {
  type        = string
  description = "Instance name for the nfs server."
  default     = "nfs-share"
}

variable "ssh_user_name" {
  type        = string
  description = "Username for ssh"
  default     = "nfs"
}

variable "nfs_path" {
  type        = string
  description = "Path to nfs_device"
  default     = "/nfs"
}

variable "nfs_ip_range" {
  type        = string
  description = "Ip range from where NFS will be available"
}

variable "mtu_size" {
  type        = string
  description = "MTU size to make network fater"
  default     = "8800"
}

variable "nfs_size" {
  type        = number
  description = "Size of the NFS in GB, should be divisbile by 93"
}

variable "nfs_device_label" {
  type        = string
  description = "device label to use later as device ID"
  default     = "nfs-disk"
}

variable "nfs_disk_name_suffix" {
  type        = string
  description = "Name suffix to be able to create several NFS disks in the same parent"
  default     = ""
}

# PUBLIC IP
variable "public_ip" {
  type        = bool
  default     = false
  description = "attach a public ip to the vm if true"
}


variable "number_raid_disks" {
  type        = number
  description = "Number of disks being used in raid"
  default     = 1
 }
