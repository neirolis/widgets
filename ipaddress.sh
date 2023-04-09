#!/bin/sh

ip=$(curl -s ipinfo.io/ip)

echo "<h3>$ip</h3>"