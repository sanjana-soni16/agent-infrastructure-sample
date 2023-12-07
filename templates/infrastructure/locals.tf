

locals {
  #Enable this to provision VPC cluster.
  create_cluster = true
  #True to create new Observability Services. False if Observability Service instances are already existing.
  enable_observability = true
}

locals {
  #Enable VPC Classic Access. Note: only one VPC per region can have classic access
  classic_access = false

  #List of subnets tiers for the vpc. For use with agents one subnet tier is defined in the VPC 
  subnet_tiers = [
    {
      name     = "vpc"
      acl_name = "vpc-acl"
      subnets = {
        zone-1 = [
          {
            name           = "subnet-a"
            cidr           = "10.10.10.0/24"
            public_gateway = true
          }
        ],
        zone-2 = [
          {
            name           = "subnet-b"
            cidr           = "10.20.10.0/24"
            public_gateway = true
          }
        ],
        zone-3 = [
          {
            name           = "subnet-c"
            cidr           = "10.30.10.0/24"
            public_gateway = true
          }
        ]
      }
    }
  ]
  #Create a public gateway in any of the three zones with `true`.
  use_public_gateways = {
    zone-1 = true
    zone-2 = true
    zone-3 = true
  }

  #List of ACLs to create. Rules can be automatically created to allow inbound and outbound traffic from a VPC tier by adding 
  #the name of that tier to the `network_connections` list. Rules automatically generated by these network connections will be 
  #added at the beginning of a list, and will be web-tierlied to traffic first. At least one rule must be provided for each ACL.
  network_acls = [
    {
      name                = "vpc-acl"
      network_connections = []
      add_cluster_rules   = true
      rules = [
        {
          name        = "allow-all-inbound"
          action      = "allow"
          direction   = "inbound"
          destination = "0.0.0.0/0"
          source      = "0.0.0.0/0"
        },
        {
          name        = "allow-all-outbound"
          action      = "allow"
          direction   = "outbound"
          destination = "0.0.0.0/0"
          source      = "0.0.0.0/0"
        }
      ]
    }
  ]
  #A list of security group rules to be added to the default vpc security group 

  ## Relook at this for agents. All access is outbound from the VPC and agent. 


  security_group_rules = [
    {
      name      = "allow-inbound"
      direction = "inbound"
      remote    = "0.0.0.0/0"
    }
  ]

}


locals {
  #Cluster locals
  #The flavor of VPC worker node to use for your cluster. Use `ibmcloud ks flavors` to find flavors for a region.
  machine_type = "bx2.4x16"
  #Number of workers to provision in each subnet
  workers_per_zone = 1
  #To avoid long wait times when you run your Terraform code, you can specify the stage when you want Terraform to mark the cluster resource creation as completed.
  #Depending on what stage you choose, the cluster creation might not be fully completed and continues to run in the background. 
  #However, your Terraform code can continue to run without waiting for the cluster to be fully created.
  #Supported args are `MasterNodeReady`, `OneWorkerNodeReady`, and `IngressReady`
  wait_till = "IngressReady"
  #List of maps describing worker pools
  worker_pools = []
}