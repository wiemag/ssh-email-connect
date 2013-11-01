ssh-email-connect
-----------------

This script is a wrapper around the ssh command. Using the inboxes of the thunderbird e-mail client, it checks the current IP of a remote host and makes it possible for the local user to connect to that host. For safety reasons, the e-mail message from the remote host informs only about the host's current IP. The remote ssh port, user login and password should be know to the local user, or key authentication should be enabled for the two computer to connect.

The remote host needs to send boot-time and shutdown notifications in a format recognizable by ssh-email-connect.

The boot-notify package/script provides a systemd service that sends the boot-time and shutdown notifications.


USAGE

	ssh-email-connect.sh [-p PORT] [-u sshUSER] [-s SUBJECT] [-r remHOST]

Default sshUSER=$USER, PORT=22. 
See the man pages. (man ssh-email-connect)

Note:  There are two opposing approaches to and expectations about how the script should work. For one thing, it should be universal. It then should recognize the different hosts and apply the correct parameters to connect. Perhaps, using defined profiles for the different hosts could be one solution. In author's opinion that would be an overkill. Instead, the author suggests using aliases in .bashrc. E.g.

	conn2neighbour='ssh-email-connect.sh -p56991 -u xyz -r neighbour'
	conn2mum='ssh-email-connrct.sh -u me -r mum'


DEPENDENCIES
- (not a dependency, but required) mozilla's thunderbird
- openssh    (command:  ssh)
- iputils2   (command:  ip)
- curl       (command:  curl)
- or wget    (command:  wget),optional
- grep       (command:  grep)
- util-linux (command:  whereis)

