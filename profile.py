import geni.portal as portal
import geni.rspec.pg as pg
import geni.rspec.igext as IG

pc = portal.Context()
request = pc.makeRequestRSpec()

tourDescription = "2-node SSO setup (LDAP server & client)."
tour = IG.Tour()
tour.Description(IG.Tour.TEXT, tourDescription)
request.addTour(tour)
link = request.LAN("lan")

# 
node1 = request.XenVM("ldapserver")    
node1.routable_control_ip = "true"  
node1.disk_image = "urn:publicid:IDN+emulab.net+image+emulab-ops:UBUNTU18-64-STD"
iface1 = node1.addInterface("if0")
iface1.component_id = "eth1"
iface1.addAddress(pg.IPv4Address("192.168.1.1", "255.255.255.0"))
link.addInterface(iface1)

# 
node2 = request.XenVM("ldapclient")
node2.routable_control_ip = "true"  
node2.disk_image = "urn:publicid:IDN+emulab.net+image+emulab-ops:UBUNTU18-64-STD"
iface2 = node2.addInterface("if1")
iface2.component_id = "eth1"
iface2.addAddress(pg.IPv4Address("192.168.1.2", "255.255.255.0"))
link.addInterface(iface2)

# Print the RSpec to the enclosing page.
pc.printRequestRSpec(request)
