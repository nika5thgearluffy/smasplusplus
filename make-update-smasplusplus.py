import os
import hashlib
import json

base_url = "https://raw.githubusercontent.com/nika5thgearluffy/smasplusplus/main/"
root_dir = "."
files = []

for dirpath, dirnames, filenames in os.walk(root_dir):
    for filename in filenames:
        filepath = os.path.join(dirpath, filename)
        rel_path = os.path.relpath(filepath, root_dir).replace("\\", "/")
        
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