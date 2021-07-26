import geni.portal as portal
import geni.rspec.pg as pg
import geni.rspec.igext as IG

# 
pc = portal.Context()
request = pc.makeRequestRSpec()
tourDescription = "Assignment-2"

#
tour = IG.Tour()
tour.Description(IG.Tour.TEXT,tourDescription)
request.addTour(tour)
link = request.LAN("lan")

# 
node0 = request.XenVM("webserver")
node0.routable_control_ip = "true"
node0.disk_image = "urn:publicid:IDN+emulab.net+image+emulab-ops:UBUNTU18-64-STD"
node0.addService(pg.Execute(shell="sh", command="bash /local/repository/apacheSetup.sh"))
iface0 = node0.addInterface("if0")
iface0.component_id = "eth1"
iface0.addAddress(pg.IPv4Address("192.168.1.1", "255.255.255.0"))

link.addInterface(iface0)

# 
node1 = request.XenVM("observer")
node1.routable_control_ip = "false"
node1.disk_image = "urn:publicid:IDN+emulab.net+image+emulab-ops:UBUNTU18-64-STD"
node0.addService(pg.Execute(shell="sh", command="bash /local/repository/nfsserver.sh"))
iface1 = node1.addInterface("if1")
iface1.component_id = "eth1"
iface1.addAddress(pg.IPv4Address("192.168.1.2", "255.255.255.0"))

link.addInterface(iface1)

# Print the RSpec to the enclosing page.
pc.printRequestRSpec(request)
