import sys, json;

data = json.load(sys.stdin)
target = float(sys.argv[1])
platform = "iOS"
SimRuntimeiOS = "com.apple.CoreSimulator.SimRuntime.iOS-"

def pair(device):
    return (device, float(device.strip(SimRuntimeiOS).replace('-', '.')))

def find(devices):
    for name, version in map(pair, filter(lambda key:key.startswith(SimRuntimeiOS), devices.keys())):
        if (version >= target):
            devices_for_name = devices[name]
            destination = devices_for_name[0]
            if devices_for_name and destination["isAvailable"]:
                return json.dumps({"platform":platform,"version":version,"destination":destination})

print find(data["devices"])
