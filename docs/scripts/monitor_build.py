import urllib.request
import json
import time
import sys

run_id = sys.argv[1]
token = "VOTRE_GITHUB_TOKEN_ICI"
url = f"https://api.github.com/repos/nadir958/doc-library-v1/actions/runs/{run_id}"

headers = {
    "Authorization": f"token {token}",
    "Accept": "application/vnd.github.v3+json"
}

print(f"Surveillance du build {run_id} démarrée...")

while True:
    req = urllib.request.Request(url, headers=headers)
    try:
        with urllib.request.urlopen(req) as response:
            data = json.loads(response.read().decode())
            status = data.get("status")
            conclusion = data.get("conclusion")
            
            if status == "completed":
                print(f"\n✅ Build terminé ! Conclusion : {conclusion}")
                break
            else:
                print(".", end="", flush=True)
    except Exception as e:
        print(f"Erreur API: {e}")
        
    time.sleep(30)
