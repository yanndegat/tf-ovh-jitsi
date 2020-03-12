# Terraform Recipe: Boot a single Jitsi Video conferencing instance on OVHCloud

## Description

This recipe helps you bootstrap a simple [Jitsi](https://jitsi.org) instance on 
OVHCloud.

This could be very useful for small teams/companies which could have an 
urging need of a simple videoconferencing solution due to covid19.

This is a very simple and stupid deployment, only secured with https and basic firewalling
feature. To use with CAUTION.

## Requirements

- an OVHCloud [public cloud](https://www.ovhcloud.com/fr/public-cloud) project.
- Hashicorp [terraform](https://www.terraform.io) 

## Getting Started

1. Create your Openstack API clouds.yaml file.

```
mkdir -p ~/.config/openstack
cat >> ~/.config/openstack/clouds.yaml <<EOF
clouds:
  jitsi:
    auth:
      auth_url: https://auth.cloud.ovh.net/v3/
      domain_name: default
      password: XXX
      project_domain_name: default
      project_name: 'YYY'
      user_domain_name: default
      username: ZZZ
    region_name: REGION
EOF
```

2. Create a tfvar file and edit accordingly

```
cp myvars.tfvars.example myvars.tfvars

```

3. apply your plan

```
terraform init
...
terraform apply
...

```

4. Go to you private meeting space.

# Ssh into the machine

You can ssh into the VM by copy/pasting the result of the following command:

```
terraform output ssh_helper
```

# Destroy the infrastructure

If you want to destroy all the resources associated with this plan, run the following
command: 

```
terraform destroy
```

## Troubleshooting

- You encounter connectivity issues

Maybe the instance is to small. Try a bigger flavor.

- This service is not HA, installed with dummy defaults. If you need 
a more reliable service, try a professional one. You can try
with [jitsi.org](https://jitsi.org) services for a start.


## License

The 3-Clause BSD License. See [LICENSE](https://github.com/yanndegat/tf-ovh-jitsi/tree/master/LICENSE) for full details.
