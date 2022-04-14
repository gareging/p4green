class Host:
  def __init__(self, id, ip, mask, mac):
       self.id = id
       self.ip = ip
       self.mask = mask
       self.mac = mac

  def __str__(self):
       return f'{self.id} ip: {self.ip} mask: {self.mask} mac: {self.mac}' 


class Link:
  def __init__(self, obj1, obj2, obj1_port, obj2_port):
     self.obj1 = obj1
     self.obj2 = obj2
     self.obj1_port = obj1_port
     self.obj2_port = obj2_port

  def __str__(self):
     port1 = self.obj1_port if self.obj1_port else ''
     port2 = self.obj2_port if self.obj2_port else ''
     obj1 = self.obj1.id if type(self.obj1) == Host else self.obj1.name
     obj2 = self.obj2.id if type(self.obj2) == Host else self.obj2.name
     return f'{obj1}:{port1}-{obj2}:{port2}'
