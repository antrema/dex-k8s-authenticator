# How to update a forked repo

## Step 1: Add the remote (original repo that you forked) and call it “upstream”
```bash
git remote add upstream https://github.com/mintel/dex-k8s-authenticator.git
```

## Step 2: Fetch all branches of remote upstream
```bash
git fetch upstream
```

## Step 3: Rewrite your master with upstream’s master using git rebase.
```bash
git rebase upstream/master
```

## Step 4: Push your updates to master. You may need to force the push with “--force”.
```bash
git push origin master --force
```