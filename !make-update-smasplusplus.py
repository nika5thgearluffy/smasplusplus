import os
import hashlib
import json
import pathspec

base_url = "https://raw.githubusercontent.com/nika5thgearluffy/smasplusplus/main/"
root_dir = "."
# Load .gitignore if it exists
gitignore_path = os.path.join(root_dir, ".gitignore")
if os.path.exists(gitignore_path):
    with open(gitignore_path, "r") as f:
        spec = pathspec.PathSpec.from_lines("gitwildmatch", f)
else:
    spec = None

files = []

for dirpath, dirnames, filenames in os.walk(root_dir):
    # Skip .git folder entirely
    dirnames[:] = [d for d in dirnames if d != ".git"]
    
    for filename in filenames:
        filepath = os.path.join(dirpath, filename)
        rel_path = os.path.relpath(filepath, root_dir).replace("\\", "/")
        
        # Skip if matches .gitignore rules
        if spec and spec.match_file(rel_path):
            continue
        
        # Skip the manifest itself and this script
        if rel_path in ("manifest.json", "generate_manifest.py"):
            continue

        with open(filepath, "rb") as f:
            md5 = hashlib.md5(f.read()).hexdigest()

        files.append({
            "path": rel_path,
            "md5": md5,
            "url": base_url + rel_path
        })

manifest = {"version": "1.0.0", "files": files}
with open("manifest.json", "w") as f:
    json.dump(manifest, f, indent=4)

print(f"Generated manifest with {len(files)} files")