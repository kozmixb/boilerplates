# Export Route53 zone

First of all we need to pull the zone records via SDK, use the following command just update `ZONE_ID`

```
aws route53 list-resource-record-sets --hosted-zone-id ZONE_ID --output json > mydomain.zone.json
```

Once the file is created, then run the following python script to convert it into bind9 style host file

> Note that at this time the converter cannot handle `alias` records which you might need to manually convert to CNAME record


```python
python3 convert.py
```

Finally we have a generated `zonefile.txt` which can be imported to any domain provider
