resource "aws_vpc" "main" {
    cidr_block = "10.0.0.0/16"

    enable_dns_hostnames = true
    enable_dns_support   = true
    
    tags = {
        Name = "${var.Name}"
        Contact = "hinkle"
    }
}

// Private Subnet
resource "aws_subnet" "private" {
    vpc_id = "${aws_vpc.main.id}"
    cidr_block = "10.0.1.0/24"
    map_public_ip_on_launch = "false" // Do we get public IP's

    tags = {
        Name = "${var.Name}-private"
        Contact = "hinkle"
    }
}

resource "aws_route_table" "private" {
    vpc_id = "${aws_vpc.main.id}"
    
    route {
        //associated subnet can reach everywhere
        cidr_block = "0.0.0.0/0" 
        nat_gateway_id = "${aws_nat_gateway.main.id}"
        //CRT uses this IGW to reach internet
        //gateway_id = "${aws_internet_gateway.main.id}" 
    }
    
    tags = {
        Name = "${var.Name}-private"
        Contact = "Hinkle"
    }
}

resource "aws_route_table_association" "main"{
    subnet_id = "${aws_subnet.private.id}"
    route_table_id = "${aws_route_table.private.id}"
}

// Public Subnet
resource "aws_subnet" "public" {
  vpc_id = "${aws_vpc.main.id}"
  cidr_block = "10.0.0.0/24"
  map_public_ip_on_launch = true
    tags = {
        Name = "${var.Name}-public"
        Contact = "hinkle"
    }
}

resource "aws_route_table" "public" {
    vpc_id = "${aws_vpc.main.id}"
    
    route {
        //associated subnet can reach everywhere
        cidr_block = "0.0.0.0/0" 
        // uses this IGW to reach internet
        gateway_id = "${aws_internet_gateway.main.id}" 
    }
    
    tags = {
        Name = "${var.Name}-public"
        Contact = "Hinkle"
    }
}

resource "aws_route_table_association" "public"{
    subnet_id = "${aws_subnet.public.id}"
    route_table_id = "${aws_route_table.public.id}"
}

// End of subnets
resource "aws_internet_gateway" "main" {
    vpc_id = "${aws_vpc.main.id}"
    tags = {
        Name = "${var.Name}"
    }
}
resource "aws_eip" "nat_gateway" {
    vpc = true
    depends_on = [aws_internet_gateway.main]
}

resource "aws_nat_gateway" "main" {
    allocation_id = "${aws_eip.nat_gateway.id}"
    subnet_id = "${aws_subnet.public.id}"

    tags = {
        Name = "${var.Name}"
        Contact = "hinkle"
    }

    depends_on = [aws_internet_gateway.main]
}

