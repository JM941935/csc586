import geni.portal as portal
import geni.rspec.pg as pg
import geni.rspec.igext as IG
pc = portal.Context()
request = pc.makeRequestRSpec()
tourDescription = "3-node SSO/NFS setup (LDAP server, NFS server, and NFS client). Both NFS nodes will be authenticated using LDAP."

#
# Setup the Tour info with the above description and instructions.
#
tour = IG.Tour()
tour.Description(IG.Tour.TEXT,tourDescription)
request.addTour(tour)
link = request.LAN("lan")

node0 = request.XenVM("ldapserver")
node0.routable_control_ip = "true"
node0.disk_image = "urn:publicid:IDN+emulab.net+image+emulab-ops:UBUNTU18-64-STD"
iface0 = node0.addInterface("if0")
iface0.component_id = "eth1"
iface0.addAddress(pg.IPv4Address("192.168.1.1", "255.255.255.0"))
link.addInterface(iface0)

node1 = request.XenVM("nfsserver")
node1.routable_control_ip = "true"
node1.disk_image = "urn:publicid:IDN+emulab.net+image+emulab-ops:UBUNTU18-64-STD"
iface1 = node1.addInterface("if1")
iface1.component_id = "eth1"
iface1.addAddress(pg.IPv4Address("192.168.1.2", "255.255.255.0"))
link.addInterface(iface1)

node2 = request.XenVM("nfsclient")
node2.routable_control_ip = "true"
node2.disk_image = "urn:publicid:IDN+emulab.net+image+emulab-ops:UBUNTU18-64-STD"
iface2 = node2.addInterface("if2")
iface2.component_id = "eth1"
iface2.addAddress(pg.IPv4Address("192.168.1.3", "255.255.255.0"))
link.addInterface(iface2)

# Print the RSpec to the enclosing page.
pc.printRequestRSpec(request)
