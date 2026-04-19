# Branching Strategy

## Branches

- `main`: integration branch for shared work
- `release/macos`: macOS-specific release branch
- `release/ios`: iOS-specific release branch

## Typical flow

1. Merge shared changes into `main`.
2. Cherry-pick or merge required commits into the relevant release branch.
3. Tag releases separately per platform.

## Example commands

```bash
git checkout release/macos
# prepare macOS release

git checkout release/ios
# prepare iOS release
```
