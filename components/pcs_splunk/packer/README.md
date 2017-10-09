
### Build image
1. copy your splunk package to the ./packer directory
2. name the splunk package file to: splank-version.tgz
3. modify the linux distribution parameter in ./params/distribution.json
4. validate the packer template: `packer validate -var-file params/amazon.json splunk.json`
5. build the image: packer build  -var-file params/amazon.json splunk.json


### Installation:
- user/group : splunk/splunk
- location: /opt/splunk
- splunk set to autostart 

### Using the image
- use the AMI ID to deploy splunk using Terraform

