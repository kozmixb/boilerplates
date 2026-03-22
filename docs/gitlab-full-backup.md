# Gitlab full backup

```bash
gitlab-backup create SKIP= STRATEGY=copy

docker exec -it gitlab gitlab-ctl stop puma
docker exec -it gitlab gitlab-ctl stop sidekiq
docker exec -it gitlab gitlab-backup restore BACKUP= force=yes
docker exec -it gitlab gitlab-ctl reconfigure
docker exec -it gitlab gitlab-ctl restart
```
