# LHTools CocoaPods 发布流程

本文档用于发布 `LHTools` 新版本到 CocoaPods。推荐流程是：用 SourceTree 检查和提交代码，用终端执行发布脚本。

## 1. 发布前准备

先进入仓库目录：

```bash
cd /Users/ciao/Desktop/github
```

确认当前工作区状态：

```bash
git status --short
```

如果没有输出，说明工作区是干净的，可以继续。

如果有输出，先在 SourceTree 里确认每个改动。常见不需要提交的文件：

```bash
Example/LHTools.xcworkspace/xcuserdata/ciao.xcuserdatad/UserInterfaceState.xcuserstate
```

这个是 Xcode 用户界面状态文件，通常不参与发布。可以丢弃：

```bash
git restore Example/LHTools.xcworkspace/xcuserdata/ciao.xcuserdatad/UserInterfaceState.xcuserstate
```

## 2. 提交发布内容

在 SourceTree 里提交本次要发布的代码改动。

如果发布脚本或发布文档也有改动，也要一起提交，例如：

```bash
scripts/release_pod.sh
scripts/cocoapods_lint_deployment_target_patch.rb
docs/release_pod.md
```

提交完成后，回到终端再次确认：

```bash
git status --short
```

正式发布前必须没有输出。发布脚本检测到工作区不干净时会停止，避免把未确认改动发布出去。

## 3. 先 dry-run 演练

假设要发布 `2.0.5`：

```bash
./scripts/release_pod.sh 2.0.5 --summary "2.0.5开发" --allow-warnings --skip-import-validation --skip-tests --dry-run
```

`--dry-run` 只打印将要执行的步骤，不会改文件、不会提交、不会打 tag、不会推送、不会发布。

如果输出里能看到类似步骤，说明流程正常：

```bash
pod lib lint LHTools.podspec ...
git tag 2.0.5
git push origin HEAD:main
git push origin 2.0.5
pod trunk push LHTools.podspec ...
```

## 4. 正式发布

确认 dry-run 没问题后，执行正式发布：

```bash
./scripts/release_pod.sh 2.0.5 --summary "2.0.5开发" --allow-warnings --skip-import-validation --skip-tests
```

发布脚本会自动执行：

1. 检查工作区是否干净
2. 更新 `LHTools.podspec` 的 `s.version`
3. 如果传了 `--summary`，同步更新 `s.summary`
4. 执行 `pod lib lint`
5. 提交 podspec 版本变更
6. 创建 git tag
7. 推送当前分支和 tag
8. 执行 `pod trunk push`

如果你已经提前在 SourceTree 里把 `LHTools.podspec` 改成目标版本并提交，脚本会跳过版本提交，继续执行 lint、tag、push 和 trunk 发布。

## 5. 发布后检查

发布完成后确认状态：

```bash
git status --short
```

查看 tag：

```bash
git tag --list 2.0.5
```

查看远程 tag：

```bash
git ls-remote --tags origin 2.0.5
```

如果需要检查 CocoaPods trunk 登录状态：

```bash
pod trunk me
```

## 6. 常见问题

### 找不到脚本

如果出现：

```bash
zsh: no such file or directory: ./scripts/release_pod.sh
```

说明当前目录不对。先进入仓库目录：

```bash
cd /Users/ciao/Desktop/github
```

再执行脚本。

### 工作区不干净

如果出现：

```bash
Error: Working tree is not clean. Commit or stash local changes before releasing.
```

先执行：

```bash
git status --short
```

然后在 SourceTree 中确认、提交或丢弃改动。确认没有输出后再发布。

### podspec 已经是目标版本

如果 `LHTools.podspec` 已经是目标版本，脚本会输出：

```bash
LHTools.podspec already has version 2.0.5. Skipping version commit.
Skipping git add/commit.
```

这是正常情况，脚本会继续执行后面的 tag、push 和 trunk 发布。

### libarclite 报错

如果 `pod lib lint` 出现类似错误：

```bash
SDK does not contain 'libarclite'
try increasing the minimum deployment target
```

这是 Xcode 新版本与部分低 deployment target 依赖 Pod 的兼容问题。发布脚本默认会加载：

```bash
scripts/cocoapods_lint_deployment_target_patch.rb
```

它只影响 lint 和 trunk push 的临时 CocoaPods 工程，会把依赖 Pods 的最低 iOS 版本提升到 `13.0`，不改发布出去的 podspec。

一般不需要手动处理。如果确实要关闭这个补丁，可以加：

```bash
--no-lint-target-patch
```

如果以后需要调整 lint 使用的最低版本，可以加：

```bash
--lint-deployment-target 14.0
```

### tag 已存在

如果提示本地 tag 已存在，说明这个版本号已经打过 tag。先确认：

```bash
git tag --list 2.0.5
git ls-remote --tags origin 2.0.5
```

如果这个版本已经发布过，不要重复发布同一个版本号，改用下一个版本，例如 `2.0.6`。

### trunk 未登录

如果 `pod trunk push` 提示权限或登录问题，先检查：

```bash
pod trunk me
```

如果未登录，需要重新注册或登录 CocoaPods trunk。

## 7. 每次发布命令模板

把版本号替换成要发布的新版本：

```bash
cd /Users/ciao/Desktop/github
git status --short
./scripts/release_pod.sh 版本号 --summary "版本号开发" --allow-warnings --skip-import-validation --skip-tests --dry-run
./scripts/release_pod.sh 版本号 --summary "版本号开发" --allow-warnings --skip-import-validation --skip-tests
```

示例：

```bash
cd /Users/ciao/Desktop/github
git status --short
./scripts/release_pod.sh 2.0.6 --summary "2.0.6开发" --allow-warnings --skip-import-validation --skip-tests --dry-run
./scripts/release_pod.sh 2.0.6 --summary "2.0.6开发" --allow-warnings --skip-import-validation --skip-tests
```
