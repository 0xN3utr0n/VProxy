# VProxy
VProxy is a Bash script that deploys virtual proxies which route traffic through OpenVPN and Tor tunnels. 
Since each proxy is isolated, you can have multiple vpn instances running at the same time. 
Furthermore, it's compatible with Proxychains, so you can create a chain of tens of vpns for, let's say, 
google dorking :) . (Beware of latency)

## Install
Since each proxy is in a container, VProxy relies heavily in Docker.  
```
cd vproxy
docker build -t vproxy . # It will take some time
```
Don't forget to copy your .ovpn files into cnf/vpn/ folder.

## Usage
```
Usage: vproxy [-opt] [command]

Options ('[]' optional fields, '<>' required fields):

	-n '<name>' .ovpn filename or identifier
	-p '<port>' Forward port
	-a '[IP1:IP2]' Allowed hosts
	-l List all running proxies
	-t Route all traffic through Tor. You->VPN->TOR->Server
	-d Show debug information
	-h This help
	-C Configure Proxychains (root required)

 Example: ./vproxy -n Europe -p 1900 -t -a 192.168.2.3:192.168.2.5:192.168.2.4

```

```
shell$ vproxy -l                                                    
   NAME			LOCAL IP		VPN IP		EXIT NODE IP
 vproxy9000		172.17.0.3         12.20.114.182/24	TOR:51.15.80.14   	
 vproxy1337		172.17.0.2         11.66.210.83/24	109.112.127.149   	
 vproxy1338		172.17.0.4         10.74.30.64/24	134.14.159.103
```

## TODO
* A more fine-grained Tor configuration.
