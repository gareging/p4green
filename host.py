from collections import deque

class Host:
  def __init__(self, name, ip, mask, mac):
       self.name = name
       self.ip = ip
       self.mask = mask
       self.mac = mac

  def __str__(self):
       return f'{self.name} ip: {self.ip} mask: {self.mask} mac: {self.mac}' 
  def __repr__(self):
       return f'{self.name}' 


class Link:
  def __init__(self, obj1, obj2, obj1_port, obj2_port):
     self.obj1 = obj1
     self.obj2 = obj2
     self.obj1_port = obj1_port
     self.obj2_port = obj2_port

  def __str__(self):
     port1 = self.obj1_port if self.obj1_port else ''
     port2 = self.obj2_port if self.obj2_port else ''
     obj1 = self.obj1.name
     obj2 = self.obj2.name
     return f'{obj1}:{port1}-{obj2}:{port2}'

def get_path(adjacency_list, src, dst):
  if src not in adjacency_list:
     return RuntimeError('Starting node is not in the graph')

  print('Get paths for', src.name, 'to', dst.name)
  queue = deque([ src ])
  visited_set = set()
  previous = {}
  out_port = {}

  while len(queue) != 0:
     #print('Visited nodes:', visited_set)
     node = queue.popleft()
     #print('At', node.name)
     if node in visited_set:
         continue
     if node == dst:
         #print('Got there!')
         #print(previous)
         path = deque([dst])
         while previous[node] in previous:
              #print('Previous hop:', previous[node])
              path.appendleft(previous[node])
              node = previous[node]
         path.appendleft(src)
         return path, out_port[path[1]]

     visited_set.add(node)
     for link in adjacency_list[node]:
         neighbor = link.obj2
         if neighbor not in out_port:
            out_port[neighbor] = link.obj1_port
         if neighbor not in visited_set:
            #print('To visit', neighbor.name)
            queue.append(neighbor)
            previous[neighbor] = node


  return []

def print_path(path):
    i = 1
    for hop in path:
       print(f'Hop {i}: {hop.name}')
       i += 1
