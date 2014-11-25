#!/usr/bin/env ruby
system("ip addr 1>out.txt 2>err.txt")
out = `cat out.txt`
regi = /inet\s(\d{3}\.\d+\.\d+\.\d+)\/\d+\sscope\sglobal/
ip = out.scan(regi).flatten[0]
p "My external IP address is: #{ip}"
File.write('ip.txt',ip.to_s)