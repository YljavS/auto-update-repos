import subprocess
from local_config import repo_arr

for repo in repo_arr:
    print(f"Updating repo: {repo}")
    subprocess.run(["./update_dev.sh", repo], check=True)