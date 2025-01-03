# GCP Settings
project   = "se-emea-sandbox"

# AZ1 Settings
region01    = "europe-west2"
az01        = ["europe-west2-a"]
cluster_name01 = "k10cluster1"

# AZ2 Settings

region02    = "europe-west2"
az02        = ["europe-west2-b"]
cluster_name02      = "k10cluster2"

# Specify the appliance instance type.
# For the list of supported instance types, review the veeam_aws_instance_type variable in the variables.tf file.
gke_num_nodes = 3
machine_type = "e2-standard-2"

# CIDR block for the new VNET where the appliance will be deployed.
subnet_cidr_block_ipv4 = "10.50.0.0/16"


#Labels
owner_gke = "patricio_cerda"
activity = "demo"
admin_password = "Veeam123!"
