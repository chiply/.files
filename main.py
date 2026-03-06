import pathlib
import os

# read files programmatically
path_repo = pathlib.Path(__file__).parent.resolve()
print(f"path repo: {path_repo}")


## TODO this requires recursive traversal
def myfunc(mypath):
    l = []
    for path, _, files in os.walk(mypath):
        for file in files:
            s = os.path.join(path, file)
            s = s.replace(f"{str(path_repo)}/files/", "")
            l.append(s)
    return l


paths = myfunc(f"{path_repo}/files")
print(f"running on {paths}")

home = os.path.expanduser('~')
for path in paths:
    target = f"{home}/{path}"
    target_dir = os.path.dirname(target)
    os.makedirs(target_dir, exist_ok=True)

symlink_commands = [
    f"ln -s -f {path_repo}/files/{path} {home}/{path}"
    for path in paths
]

print("\nsymlink commands")
for cmd in symlink_commands:
    print(cmd)

for cmd in symlink_commands:
    print('running {cmd}')
    os.system(cmd)
