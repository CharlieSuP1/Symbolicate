require 'json'
require "fileutils"

def findDSYM(version)

  def findDSYMZip(version)
    #1. 首先在temp/version目录寻找
    dSYM = Dir.glob("temp/#{version}/*.app.dSYM").first
    if dSYM.nil?
      #2.找不到的话，在当前目录下有没有 version + dSYM.zip 这样命名的文件
      dSYM = Dir.glob("*#{version}*.dSYM.zip").first
      if dSYM.nil?
        raise "找不到 *#{version}*.dSYM.zip 类似命名的文件"
      end

      #3.解压缩到temp/version
      Dir.mkdir("temp/#{version}")
      `#{"unzip #{dSYM} -d temp/#{version}/"}`

      #4.获取*app.dSYM文件
      dSYM = Dir.glob("temp/*#{version}/*app.dSYM").first
      if dSYM.nil?
        raise "解压缩.dSYM.zip 后找不到app.dSYM文件"
      end
    end
    dSYM
  end

  dSYM = ""
  begin
    dSYM = findDSYMZip(version)
  rescue
    dSYM = Dir.glob("*.app.dSYM").first
  end
  if dSYM.nil? || dSYM.length == 0
    raise "没有找到符号表"
  end
  dSYM
end

`rm -rf temp`
Dir.mkdir("temp")

Dir.glob(["**/*.ips"]).each do |name|

  File.open("#{name}") do |f|
    firstLine = f.readline
    obj = JSON.parse(firstLine)
    buildVersion = obj["build_version"]

    begin
      dSYM = findDSYM(buildVersion)
      puts dSYM
      fileName = name.split('/').last
      `#{"./symbolicate -v #{name} #{dSYM} > #{fileName}.txt"}`
    rescue
      puts "没有找到 version: #{buildVersion} 符号表"
    end
  end
end

puts "如果系统符号没有还原，请参考：https://github.com/Zuikyo/iOS-System-Symbols"