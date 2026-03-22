import os

import requests
from dotenv import load_dotenv

load_dotenv()

GITLAB_API_TOKEN = os.getenv("GITLAB_API_TOKEN")
GITLAB_URL = os.getenv("GITLAB_URL")
GITEA_API_TOKEN = "your_gitea_api_token"
GITEA_URL = "https://your_gitea_instance.com"
EXPORT_DIR = "exported_repos"


def get_headers(token: str) -> dict[str, str]:
    return {
        "Private-Token": token,
        "Content-Type": "application/json",
    }


def get_repositories():
    url = f"{GITLAB_URL}/api/v4/projects"
    headers = get_headers(GITLAB_API_TOKEN)
    all_repos = []
    page = 1
    per_page = 10

    while True:
        params = {
            "page": page,
            "per_page": per_page,
        }
        response = requests.get(url, headers=headers, params=params)
        response.raise_for_status()
        repos = response.json()

        if not repos:
            break

        all_repos.extend(repos)
        page += 1

    return all_repos


def clone_repository(project):
    repo_name = project["name"]
    repo_url = project["http_url_to_repo"]
    repo_path = os.path.join(EXPORT_DIR, repo_name)
    if not os.path.exists(repo_path):
        token = GITLAB_API_TOKEN
        tokenized_url = f"https://oauth2:{token}@{repo_url.replace('https://', '')}"
        os.makedirs(repo_path)
        os.system(f"git clone {tokenized_url} {repo_path}")


def main():
    if not os.path.exists(EXPORT_DIR):
        os.makedirs(EXPORT_DIR)

    repositories = get_repositories()
    for repo in repositories:
        clone_repository(repo)


if __name__ == "__main__":
    main()
