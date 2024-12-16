# Docker for Novel Games

DockerによるノベルゲームのためのWineコンテナ

## 動作確認

- FORTUNE ARTERIAL
- WHITE ALBUM2 EXTENDED EDITION

## FORTUNE ARTERIAL

```
MESA: error: Failed to query drm device.
glx: failed to create dri3 screen
failed to load driver: iris
failed to open /dev/dri/card1: No such file or directory
failed to load driver: iris
```

こんな感じのエラーはIntelのGPUを認識できないことが原因なので、Dockerのオプションとして`--device /dev/dri:/dev/dri`を与えてやれば良い。ただ、ゲームは動くので必須ではない。

## WHITE ALBUM2

### X11周りの設定

このようなエラーが出たが、[同じエラーで質問している記事](https://forum.winehq.org/viewtopic.php?t=31336)や、Wine公式のWikiで取り上げられている[便利な設定](https://gitlab.winehq.org/wine/wine/-/wikis/Useful-Registry-Keys)を参照して対処した。

```
X Error of failed request:  XF86VidModeClientNotLocal
  Major opcode of failed request:  152 (XFree86-VidModeExtension)
  Minor opcode of failed request:  18 (XF86VidModeSetGammaRamp)
  Serial number of failed request:  278
  Current serial number in output stream:  280
```

具体的な内容は以下の通り。レジストリに推奨設定を書き込んだあと、レジストリファイルの変更を見て実際に書き込まれたかを確認する。確認しないと設定が保存しないままDockerfileが次のステップに移ってしまう。尚、この確認方法ではどちらか一方だけが書き込まれ、その他が書き込まれていない状況でも通ってしまう[懸念](https://serverfault.com/questions/1082578/wine-in-docker-reg-add-only-keeps-effects-temporarily)がある。

```Dockerfile
RUN before=$(stat -c '%Y' ${HOME}/.wine/user.reg) &&\
    wine reg add "HKCU\Software\Wine\X11 Driver" /v UseXRandR /t REG_SZ /d N /f && \
    wine reg add "HKCU\Software\Wine\X11 Driver" /v UseXVidMode /t REG_SZ /d N /f && \
    while [ $(stat -c '%Y' ${HOME}/.wine/user.reg) = $before ]; do sleep 1; done
```

### DirectXと動画の再生

WHITE ALBUM2はDirectX 9に依存しているので、`d3dx9`のインストールが必要。尚、`dxvk`をインストールしてはいけない。古いゲームを動かす上ではVulkanベースの`dxvk`は意図しない動作の原因になりやすい。実際、WHITE ALBUM2を動かす際に`dxvk`をDirectXとしてインストールしていたが、動画の再生ができなかった。

また、wmvやmpegの再生のために`wmp9`をインストールしている。「`gstreamer`の変わりに`quartz`を使用すべき」といった記事が散見されたが、現在のWineではgstreamerで十分動作するようである。

因みに、`mv\d{2}0.pak`や`ev\d{2}0.pak`と言ったファイルは拡張子を`wmv`に変えることで動画として再生できる。
