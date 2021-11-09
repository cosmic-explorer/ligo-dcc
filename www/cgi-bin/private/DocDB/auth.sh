#!/bin/ksh

echo "---------------" > /tmp/mygroup.out
echo "<b>Arguments:</b>" >> /tmp/mygroup.out
echo $* >> /tmp/mygroup.out
echo "\n<b>Environment:</b>" >> /tmp/mygroup.out
/usr/bin/env >> /tmp/mygroup.out
echo "\n<b>Stdin:</b>" >> /tmp/mygroup.out
cat >> /tmp/mygroup.out
echo "---------------" >> /tmp/mygroup.out

exit 0
