# Network Traffic Limiter

Limit network device activity based on specific rules on a home network, currently using **Asus-Merlin** compatible device.

The program will basically monitor the internet traffic and the device status, and disable that device if the amount of time spent that day/week exceed a specified limit.

The main idea is to send the current device usage to a remote device capable to display that data (an Android App or a simple device based on Arduino/RPI with an LCD/Led display).

All of this for educating us creating "good habit" on network device usage, increasing our awareness on how much time we spend daily on some activity, like playing with the PS4, sacrificing another one, like going out for a walk.

## Gather information

The router should have the _Asus-Merlin_ firmware installed, and the _ssh_ access enabled.

### Get list of devices

We can get the list of currently connected devices issuing one of the following command:

```
admin@RT-AC68U:/# bwdpi device
...
admin@RT-AC68U:/# cat /tmp/clientlist.json
...
```

### Get Web Traffic

We can update web traffic information issuing the command:

```
admin@RT-AC68U:/# WebHistory -e
```

We can access web traffic information accessing the sqlite db located here:

```
admin@RT-AC68U:/# sqlite3 /jffs/.sys/TrafficAnalyzer/TrafficAnalyzer.db
SQLite version 3.7.2
Enter ".help" for instructions
Enter SQL statements terminated with a ";"
sqlite> .table
history
sqlite> .schema
CREATE TABLE history(mac TEXT NOT NULL,timestamp UNSIGNED BIG INT NOT NULL,url TEXT NOT NULL);
CREATE INDEX mac ON history(mac ASC);
CREATE INDEX timestamp ON history(timestamp ASC);
CREATE INDEX url ON history(url ASC);
```

### Get Traffic Analisys

We can update traffic analisys information issuing the command:

```
admin@RT-AC68U:/# TrafficAnalyzer -e
```

We can access web traffic information accessing the sqlite db located here:

```
admin@RT-AC68U:/# sqlite3 /jffs/.sys/TrafficAnalyzer/TrafficAnalyzer.db
SQLite version 3.7.2
Enter ".help" for instructions
Enter SQL statements terminated with a ";"
sqlite> .table
traffic
sqlite> .schema
CREATE TABLE traffic(mac TEXT NOT NULL,app_name VARCHAR(50) NOT NULL,cat_name VARCHAR(50) NOT NULL,timestamp UNSIGNED BIG INT NOT NULL,tx UNSIGNED BIG INT NOT NULL,rx UNSIGNED BIG INT NOT NULL);
CREATE INDEX app_name ON traffic(app_name ASC);
CREATE INDEX cat_name ON traffic(cat_name ASC);
CREATE INDEX mac ON traffic(mac ASC);
CREATE INDEX timestamp ON traffic(timestamp ASC);
```

## Limit device access

We can limit network access to a device updating the two mac address list:

- wl0_maclist_x for 2.4Ghz
- wl1_maclist_x for 5.0Ghz

The [user script](https://github.com/RMerl/asuswrt-merlin.ng/wiki/User-scripts) section of the online documentation describe the procedure for inserting a new script into the system.

The following commands will update the mac address black list and block that device:

```
maclist="<mac1>client1<mac2>client2"
nvram set wl0_maclist_x=$maclist
nvram set wl1_maclist_x=$maclist
nvram commit
service restart_wireless
```

## Cross compiling

We need to cross-compile an application for the MIPS architecture, and we need to setup the environment as described in [this guide](https://github.com/RMerl/asuswrt-merlin.ng/wiki/Compile-Firmware-from-source-using-Ubuntu).

The following example can be used as a starting point:

```
CC = mipsel-uclibc-gcc
CFLAGS = -O2 -Wall -pipe -mtune=mips32r2 -mips32r2 -isystem /home/youruser/asuswrt-merlin/release/src-rt/linux/linux-2.6/include -I./include
OFILES = main.o otherfile.o

TARGET = yourprogram

all:    $(TARGET)

$(TARGET): $(OFILES)
        $(CC) $(OFILES) -o $(TARGET)
        chmod 4711 $(TARGET)

main.o: Makefile main.c include/main.h include/otherfile.h
        $(CC) $(CFLAGS) -c main.c

otherfile.o: Makefile comm.c include/main.h include/otherfile.h
        $(CC) $(CFLAGS) -c comm.c

clean:
        rm -f $(TARGET) *.o
```

## References

- [AsusWrt Merlin firmware](https://github.com/RMerl/asuswrt-merlin) by Eric Sauvageau
- [AsusWrt script example](https://github.com/mgor/asuswrt-scripts) by Mikael Göransson
