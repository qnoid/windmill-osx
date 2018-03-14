import sys, json;

data = json.load(sys.stdin)
target = float(sys.argv[1])
platform = "iOS"

def pair(device):
    return (device, float(device.strip(platform)))

def find(devices):
    for name, version in map(pair, filter(lambda key:key.startswith(platform), devices.keys())):
        if (version >= target):
            devices_for_name = devices[name]
            if devices_for_name:
                return json.dumps({"platform":platform,"version":version,"destination":devices_for_name[0]})

print find(data["devices"])
