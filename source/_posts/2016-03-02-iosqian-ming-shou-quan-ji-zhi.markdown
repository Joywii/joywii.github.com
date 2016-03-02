---
layout: post
title: "iOS签名授权机制"
date: 2016-03-02 15:31:09 +0800
comments: true
categories: 
---
####几个重要的概念
#####1. 非对称加密
非对称加密算法需要两个密钥：`公开密钥（publickey`）和`私有密钥（privatekey）`。公开密钥与私有密钥是一对，如果用公开密钥对数据进行加密，只有用对应的私有密钥才能解密；如果用私有密钥对数据进行加密，那么只有用对应的公开密钥才能解密。（私钥是要保密的，公钥可以公开）
`RSA`是目前最有影响力的公钥加密算法，它能够抵抗到目前为止已知的绝大多数密码攻击，已被ISO推荐为公钥数据加密标准。`RSA`是以三个发明者的姓氏首字母组成的。
#####2. 摘要算法
数据摘要算法是密码学算法中非常重要的一个分支，它通过对所有数据提取指纹信息以实现数据签名、数据完整性校验等功能，由于其不可逆性，有时候会被用做敏感信息的加密。数据摘要算法也被称为哈希（Hash）算法、散列算法。
摘要算法也可以理解为将任意长度的数据，通过一个算法，得到一个固定长度的数据。典型的摘要算法，比如大名鼎鼎的`MD5`和`SHA`。
#####3. 数字签名
数字签名就是利用`非对称加密`和`摘要算法`来传输数据，保证数据的`完整性`和`合法性`。验证过程如下：
1. 发送方使用给一个摘要算法（`MD5`）得到要发送数据的摘要，然后用自己的私钥和一个非对称加密算法（`RSA`）对得到的摘要加密，得到加密后的数据，然后将`要发送的数据`、`加密后的数据`、`摘要算法`和`加密算法`一同发送给接收方。
2. 接收方接收到数据后，根据指定的摘要算法（`MD5`）得到实际要传输的数据的摘要，然后在根据指定的加密算法（`RSA`）和已有的公钥解密得到加密数据解密后的数据，最后比较解密后的数据和得到的摘要是否相同，如果相同就说明实际要传输的数据是完成的合法的。

![](http://img.itc.cn/photo/o41PBy3DAqp)

#####4. 数字证书
数字证书就是通过数字签名方式来传输的一段数据，iOS开发中的数字证书是Apple Worldwide Developer Relations Certification Authority(WWDR)证书认证中心数字签名过的数据，表面上我们看到的就是钥匙串中的证书，实际WWDR数字签名后的证书包含以下内容：
> - 用户的公钥
> - 用户信息
> - 证书机构名称
> - 证书有效期
> - **苹果数字签名 ： 用于验证以上信息**

####iOS签名验证流程
整个过程的前提是已经购买了苹果的开发者账号（\$99或\$299）。并且安装了`Xcode`，因为安装`Xcode`的过程中会自动安装苹果的开发者根证书（`Apple Worldwide Developer Relations Certification Authority`）。这证书包含了苹果CA的`公钥`。有了这个公钥，我们和Apple就可以进行互信的信息传递。整个过程大致如下：

![](http://img.itc.cn/photo/j41PB2NQfCg)

#####一. 证书申请
1. 用我们自己的机器生成`CertificateSigningRequest.certSigningRequest`文件，在生成的过程中会产生一对公钥和私钥，私钥已经保存在我们的机器上，这个文件包含了我们的公钥，具体内容如下：
> - 申请者信息，此信息是用申请者的`私钥`加密的。
> - 申请者公钥，此信息是申请者使用的`私钥`对应的公钥。
> - 摘要算法和公钥加密算法

2. 上传`CertificateSigningRequest.certSigningRequest`到`MemberCenter`。`MemberCenter`根据获取到的`公钥`和我们的用户信息，通过`Apple`自己的私钥进行数字签名生成证书，这个证书可以通过安装`Xcode`过程中安装的根证书进行验证。具体证书包含内容如下：
> - 用户的公钥
> - 用户信息
> - 证书机构名称
> - 证书有效期
> - **苹果数字签名 ： 通过根证书验证以上信息**

3. 下载生成的证书，双击安装就会出现在`钥匙串`中，`钥匙串`会根据证书中的公钥对应上本机器上的私钥。

![](http://img.itc.cn/photo/j41PBVh1nJ1)

#####二. 打包签名
1. 在`MemberCenter`上生成`mobileprovision`下载安装，`mobileprovision`包含如下信息：
> - **appid：**每个`app`在 `MemberCenter`创建的对应的`id`。
> - **包含哪些证书：**不同证书对应不同功能。
> - **功能授权列表**
> - **可安装的设备列表：**iOS设备的UDID列表，发布证书应该是通配。
> - **苹果数字签名：**苹果用来验证以上的信息。

2. 通过`Xcode`指定要使用的证书，其实是 指定了签名过程中要使用的`私钥`，这个私钥是和证书中的公钥相对应的。然后指定对应的`mobileprovision`，由于`mobileprovision`文件中包含了证书，实际上本地证书就是`Xcode`用来指定对应`私钥`用的。
3. 最后通过指定的私钥对需要签名的数据进行数字签名（编译过程在签名之前，这里省略了编译过程，编译后的二进制文件也是要签名的内容），最终将`ipa`包的形式输出，`ipa`的文件结构如下：

![](http://img.itc.cn/photo/j41PB96mIrt)
> - **资源文件：**例如图片、html、等等。
> - **_CodeSignature/CodeResources：**plist文件，内容是包内所有数据的数字签名。
> - **可执行文件：**编译后的二进制文件。
> - **mobileprovision：**我们之前通过Xcode指定的包含了证书的文件。
> - **Frameworks：**程序引用的非系统自带的Frameworks。每个Framework的结构跟app其实差不多

#####三. 验证安装
1. 解压`ipa`包，获取`embedded.mobileprovision`，通过设备上的`Apple`公钥验证该文件的完整性和安全性。
2. `embedded.mobileprovision`文件验证通过，获取该文件内的用户证书，再通过设备上的`Apple`公钥验证该证书的完整性和安全性。
3. 证书验证通过后，获取证书内的我们开发者的公钥。然后通过开发者的公钥验证应用程序包内的数据的完整性和安全性。通过后即可安装。

####参考资料

1. [漫谈iOS程序的证书和签名机制](http://www.pchou.info/ios/2015/12/14/ios-certification-and-code-sign.html)
2. [iOS Code Signing 学习笔记](http://foggry.com/blog/2014/10/16/ios-code-signing-xue-xi-bi-ji/)
3. [Inside Code Signing](https://www.objc.io/issues/17-security/inside-code-signing/)
4. [代码签名探析](http://objccn.io/issue-17-2/)
5. [iReSign](https://github.com/maciekish/iReSign)