variable "AWS_REGION" {    
    default = "us-west-1"
}

variable "Name" {
    default = "terraform-test"
}

variable "AMI" {
    type = map(string)
    
    default = {
        // Amazon Linux 2 AMI (HVM), SSD Volume Type - (64-bit x86)
        us-west-1 = "ami-04468e03c37242e1e"
        // This is 16.04 LTS Ubuntu on AMD64
        us-west-2 = "ami-0dd273d94ed0540c0"

        // Don't know what these are, just here for map example
        eu-west-2 = "ami-03dea29b0216a1e03"
        us-east-1 = "ami-0c2a1acae6667e438"
    }
}
