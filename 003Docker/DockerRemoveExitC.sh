#!/bin/bash
#author:james.liu
#Wed Jan 16 10:32:46 CST 2019
#移除docker中exit状态的进程
for i in `docker ps -a |grep Exited |awk '{print $1}'`;do docker rm $i ;done

