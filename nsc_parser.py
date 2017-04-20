import re
from datetime import datetime

reg = '(?P<date>[0-9]{4}\-[0-9]{2}\-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2})\s\[(?P<level>[^\]]+)\](?:\s\[([^\]]+)\])?(?:\s\[([^\]]+)\])?(?:\s\[([^\]]+)\])?(?:\s\[([^\]]+)\])?(?:\s\[([^\]]+)\])?\s(?P<text>(?:.*\s(?P<file>\/[^\s]+)\.\s)?.*)'

class Entry(object):
    def __init__(self, date, level, text, other, files=None):
        self.date = datetime.strptime(date, '%Y-%m-%dT%H:%M:%S')
        self.level = level
        self.text = text
        self.other = other
        self.files = files

def parse(filename):
  log = []

  with open(filename, 'r') as f:
    for line in f.readlines():
        m = re.search(reg, line)
        if m == None:
            continue
            
        if m.groupdict()['text'] == '':
            continue
            
        other = [x for x in m.groups() if x not in m.groupdict().values() and x is not None]
        otherkeys = []
        othervals = []
        for x in other:
            if ":" in x[0:20]:
                otherkeys.append(x.split(':')[0])
                othervals.append(x.split(':')[1])
            else:
                otherkeys.append(x)
                othervals.append(x)
                
        other2 = {}
        for k, v in zip(otherkeys, othervals):
            other2[k] = v
           
        log.append(Entry(m.groupdict()['date'], m.groupdict()['level'], m.groupdict()['text'], other2, m.groupdict()['file']))
        
  return log
    
