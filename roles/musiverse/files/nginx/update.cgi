#!/bin/sh

echo "HTTP/1.1 303 See Other"
echo "Location: /Update"
echo ""
echo "<head>"
echo "<html><script>alert('Update angestoßen');</script>"
echo "update musiverse. this may take a while"
echo "</html>"

sudo -u "muser" touch /tmp/update_musiverse
