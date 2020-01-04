# IPTables Easy Drop Script

Easily block all communication with a given IP address or network

## Installation

There are no installation steps you will need to perform.
On the first run, the script will do the following automatically. Existing rules should not be affected.

1) The `blocks` chain is created
2) A `RETURN` rule is added to the end of the `blocks` chain
3) A jump to the `blocks` chain is inserted at the first position in the `PREROUTING` chain
4) Blocked IP address/network is added to the `blocks` chain before the `RETURN` rule

## Usage

```
drop.sh <ip_address>
drop.sh <subnet>
```

### Examples

Blocking a `/24` network
```
./drop.sh 8.8.8.0/24
Dropping 8.8.8.0/24 ... DONE
```

Blocking a single IP address
```
./drop.sh 1.1.1.1
Dropping 1.1.1.1 ... DONE
```

## Before First Run

How an empty `raw` table looks before the first run of this script
```
$ iptables -t raw -L -v -n --line-numbers
Chain PREROUTING (policy ACCEPT 35 packets, 2420 bytes)
num   pkts bytes target     prot opt in     out     source               destination

Chain OUTPUT (policy ACCEPT 20 packets, 2271 bytes)
num   pkts bytes target     prot opt in     out     source               destination
```

## After First Run

```
$ iptables -t raw -L -v -n --line-numbers
Chain PREROUTING (policy ACCEPT 33 packets, 2837 bytes)
num   pkts bytes target     prot opt in     out     source               destination
1       76  5873 blocks     all  --  *      *       0.0.0.0/0            0.0.0.0/0

Chain OUTPUT (policy ACCEPT 22 packets, 1823 bytes)
num   pkts bytes target     prot opt in     out     source               destination

Chain blocks (1 references)
num   pkts bytes target     prot opt in     out     source               destination
1        0     0 DROP       all  --  *      *       1.1.1.1              0.0.0.0/0            /* BLOCK 1.1.1.1 */
2       76  5873 RETURN     all  --  *      *       0.0.0.0/0            0.0.0.0/0
```
