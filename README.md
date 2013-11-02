ssh-email-connector
-------------------

This script is a wrapper around the ssh command. Using the inboxes of the thunderbird e-mail client, it checks the current IP of a remote host and makes it possible for the local user to connect to that host. For safety reasons, the e-mail message from the remote host informs only about the host's current IP. The remote ssh port, user login and password should be known to the local user, or SSH key authentication should be enabled for the two computers to connect.

The remote host needs to send boot-time and shutdown notifications in a format recognizable by ssh-email-connector.

The boot-notify package/script provides a systemd service that sends the boot-time and shutdown notifications.


USAGE

	ssh-email-connector [-p PORT] [-u sshUSER] [-s SUBJECT] [-r remHOST]

Default sshUSER=$USER, PORT=22. 
See the man pages. (man ssh-email-connect)

Note:  There are two opposing approaches to and expectations about how the script should work. For one thing, it should be universal. It then should recognize the different hosts and apply the correct parameters to connect. Perhaps, using defined profiles for the different hosts could be one solution. In author's opinion that would be an overkill. Instead, the author suggests using aliases in .bashrc. E.g.

	conn2neighbour='ssh-email-connector -p56991 -u xyz -r neighbour'
	conn2mum='ssh-email-connector -u me -r mum'
	conn2m='ssh-email-connector -u me -r m$'

The last example shows how to differentiate between the 'mum' and 'm' host names. Of course, in this example the remote host name must be the last word in the subject.


DEPENDENCIES
- (not a dependency, but required) mozilla's thunderbird
- openssh    (command:  ssh)
- iproute2   (command:  ip)
- curl       (command:  curl)
- or wget    (command:  wget),optional
- grep       (command:  grep)
- util-linux (command:  whereis)

