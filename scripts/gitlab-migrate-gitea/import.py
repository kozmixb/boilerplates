import os
import subprocess

import requests
from dotenv import load_dotenv

load_dotenv()

GITEA_API_TOKEN = os.getenv("GITEA_API_TOKEN")
GITEA_URL = os.getenv("GITEA_URL")
EXPORT_DIR = "exported_repos"


def get_headers() -> dict[str, str]:
    return {
        "Authorization": f"token {GITEA_API_TOKEN}",
        "Content-Type": "application/json",
    }


def create_repository(name: str, description: str, private: bool = True) -> str:
    url = f"{GITEA_URL}/api/v1/user/repos"
    headers = get_headers()
    payload = {
        "name": name,
        "description": description,
        "private": private,
        "auto_init": False,
    }
    response = requests.post(url, headers=headers, json=payload)

    if response.status_code == 409:
        print(f"--- [!] Repo '{name}' already exists on Gitea. Skipping creation.")
        # We still need the URL to push updates
        user_info = requests.get(
            f"{GITEA_URL}/api/v1/user", headers=get_headers()
        ).json()
        return f"{GITEA_URL}/{user_info['username']}/{name}.git"

    response.raise_for_status()
    return response.json()["clone_url"]


def push_to_gitea(local_path: str, remote_url: str) -> None:
    """Handles the actual 'git push' of all branches and tags."""
    auth_url = remote_url.replace("://", f"://{GITEA_API_TOKEN}@")

    try:
        print(f"--- Pushing {local_path} to Gitea...")
        subprocess.check_call(
            ["git", "-C", local_path, "push", "--mirror", auth_url],
            stdout=subprocess.DEVNULL,
        )
        print(f"--- [+] Successfully migrated {local_path}")
    except subprocess.CalledProcessError as e:
        print(f"--- [X] Failed to push {local_path}: {e}")


def main():
    repositories = os.listdir(EXPORT_DIR)
    for repo_name in repositories:
        repo_path = os.path.join(EXPORT_DIR, repo_name)
        if not os.path.isdir(repo_path) or not os.path.exists(
            os.path.join(repo_path, ".git")
        ):
            continue

        desc_path = os.path.join(repo_path, ".git/description")
        description = ""
        if os.path.exists(desc_path):
            with open(desc_path, "r") as f:
                description = f.read().strip()

        try:
            clone_url = create_repository(repo_name, description)
            push_to_gitea(repo_path, clone_url)

        except requests.exceptions.HTTPError as e:
            print(f"--- [X] API Error for {repo_name}: {e}")


if __name__ == "__main__":
    main()
