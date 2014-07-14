# portacluster-scripts

This is a set of trivial scripts for rapid iteration and repeatable node
setup on my cluster of Intel NUCs.

# instructions

Pull this repo or rsync it to the target host. Run apply.sh _in your user account_.

e.g.

atobey@node1: ./bin/apply.sh

State data is written to /var/cache/portacluster-scripts and logs are in /var/cache/portacluster-scripts/log by date.

Using my [perl-ssh-tools](https://github.com/tobert/perl-ssh-tools) this can be run across the cluster in moments.

```
git push
cl-run.pl --list portacluster -c "cd ~/src/scripts && git pull && ./bin/apply"
```

# why not my\_favorite\_config\_tool?

Because I wrote this ages ago and it's still easier (for me) for rapid iteration
than any of the modern tools I've tried. It is not meant to be used to manage
hoardes of production servers, it is not portable across distros or even newer
versions of a distro. Less abstraction = less to think about = faster iteration.
Those abstractions are helpful in large/diverse environments and you should use them.

