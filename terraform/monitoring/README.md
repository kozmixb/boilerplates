# Grafana

Dashboards to import
- https://grafana.com/grafana/dashboards/14279-cronjobs/
- https://grafana.com/grafana/dashboards/22128-horizontal-pod-autoscaler-hpa/
- https://grafana.com/grafana/dashboards/11454-k8s-storage-volumes-cluster/
- https://grafana.com/grafana/dashboards/8685-k8s-cluster-summary/
- https://grafana.com/grafana/dashboards/18862-karpenter/
- https://grafana.com/grafana/dashboards/11270-kubecost/
- https://grafana.com/grafana/dashboards/741-deployment-metrics/
- https://grafana.com/grafana/dashboards/1860-node-exporter-full/
- https://grafana.com/grafana/dashboards/13332-kube-state-metrics-v2/

# Prometheus Alerting

will need to create a secret per environment with the following config template

```json
{
  "slack_api_url": "https://hooks.slack.com/services/.......",
  "slack_channel": "#alerts-testing",
  "smtp_to": "alarm@yourcompany.co.uk",
  "stmp_from": "alarm@yourcompany.co.uk",
  "smtp_host": "email-smtp.eu-west-2.amazonaws.com:587",
  "smtp_auth_username": "",
  "smtp_auth_password": ""
}
```
