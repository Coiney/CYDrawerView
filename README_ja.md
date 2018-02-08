# CYDrawerView

開閉可能なメニューウィジェット

![Example](.readme_images/example.png "Example")

## 概要

グレーの部分をタップするか、上下にドラッグすると開閉できます。

## 使用方法

`CYDrawerView.[mh]` をXcodeのターゲットに追加し、下記の「Interface Builder」「コード」のいずれかの方法でビューコントローラに追加します。

### Interface Builder

2. Interface Builderで `UIView` を作成し、ビュー下部に配置します。
3. Identity Inspectorで、 `UIView` のクラスを `CYDrawerView` に変更します。

![Example](.readme_images/ib.png "Adding CYDrawerView to a Storyboard")

`DrawerDemo/DrawerDemo.xcodeproj` にサンプルプロジェクトがあります。

### コード

このコードを viewDidLoad() に追加してください。

```
let drawerView = CYDrawerView.init()
drawerView.dataSource = self
drawerView.delegate = self
drawerView.translatesAutoresizingMaskIntoConstraints = false

self.view.addSubview(drawerView)

// Add layout constraints
self.view.addConstraints(NSLayoutConstraint.constraints(
    withVisualFormat: "H:|-0-[drawerView]-0-|",
    options: [],
    metrics: nil,
    views: ["drawerView": drawerView]))
self.view.addConstraints(NSLayoutConstraint.constraints(
    withVisualFormat: "V:[drawerView(60)]-|",
    options: [],
    metrics: nil,
    views: ["drawerView": drawerView]))
```

## 動作環境

* Xcode 8
* iOS 8.0 以上