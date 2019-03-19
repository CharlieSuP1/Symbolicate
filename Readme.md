1.在zshrc中添加 alias symbolicate="ruby #{PATH_OF_THIS_REPO}/symbolicate.rb"
2.把所有的crash文件(.ips格式), 符号文件放到一起。在该目录下执行symbolicate
 
支持多个版本的crash文件，符号文件，同时解析。
只需crash文件头中version和符号文件名字相匹配就行。
crash文件会被递归寻找，符号文件只在当前目录下寻找。
 

