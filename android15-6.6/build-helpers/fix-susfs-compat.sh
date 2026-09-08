#!/bin/bash
# Android 15 / Linux 6.6 SUSFS compatibility fix.
set -e

TMU="$1/fs/proc/task_mmu.c"
[ -f "$TMU" ] || exit 0

python3 - "$TMU" <<'PYEOF'
import re, sys
p = sys.argv[1]
with open(p) as f:
    lines = f.readlines()
for i, line in enumerate(lines):
    if 'struct pagemapread pm;' not in line:
        continue
    for j in range(i + 1, min(i + 12, len(lines))):
        if re.search(r'struct vm_area_struct \*vma\s*;', lines[j]) and '__maybe_unused' not in lines[j]:
            lines[j] = re.sub(r'struct vm_area_struct \*vma\s*;', 'struct vm_area_struct *vma __maybe_unused;', lines[j])
            with open(p, 'w') as out:
                out.writelines(lines)
            print('marked pagemap_read vma maybe-unused')
            break
    break
PYEOF
