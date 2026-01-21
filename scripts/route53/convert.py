import json

# Load the JSON file
with open('mydomain.zone.json') as f:
    data = json.load(f)

# Convert JSON to DNS Zone file format
def convert_to_zone_file(data):
    zone_file = []
    for record in data['ResourceRecordSets']:
        if 'AliasTarget' in record:
            print('WARNING: exported records contains alias record which has been excluded from the zone file')
            continue

        name = record['Name']
        record_type = record['Type']
        ttl = record['TTL']
        values = [entry['Value'] for entry in record['ResourceRecords']]
        
        for value in values:
            zone_file.append(f"{name} {ttl} IN {record_type} {value}")
    
    return "\n".join(zone_file)

# Generate the zone file content
zone_content = convert_to_zone_file(data)

# Save the result to a file
output_file = "zonefile.txt"
with open(output_file, 'w') as f:
    f.write(zone_content)

print(f"Zone file generated: {output_file}")
