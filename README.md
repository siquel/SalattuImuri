# SalattuImuri
Custom automatic rsync downloader for my needs

# Config file
imuri.conf
```sh
# grouping 
[group src resolution]
^regex$ = /path/to/dl/location/
^anotherserie.+$ = /path/to/dl/location/anotherserie/
^person.of.interest.+$ = /path/to/dl/location/person/

# server stuff
[server servername]
username = myuser
port = 22
hostname = box.example.com
root = /mnt/stuff/
```
