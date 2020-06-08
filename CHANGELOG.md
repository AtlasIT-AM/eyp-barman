# CHANGELOG

# 0.2.19

* added support for **eyp-postgres 0.5**

# 0.2.18

* added snmpd support

# 0.2.16

* bugfix barman server report

# 0.2.15

* changed return code for the barman server report

# 0.2.14

* added report for **barman check**

# 0.2.13

* added **psycopg2** to the barman installation

# 0.2.12

* Added **check_barman_servers** to make sure it is in compliance
* Renamed backup check **check_barman_backups**
  - Check number of available backups

# 0.2.10

* improved error check for **check_barman_backups_failed**

# 0.2.9

* added **check_barman_backups_failed** for making sure there are no FAILED backups

## 0.2.7

* added support for eyp-postgresql 0.4.0 branch

## 0.2.6

* improved barman backup script output

## 0.2.5

* bugfix barman backup script

## 0.2.4

* **barman::backup** improvement

## 0.2.3

* bugfix barman backup script

## 0.2.2

* bugfix manage_package

## 0.2.1

* added IDHOST in the log path for the barman backup script

## 0.2.0

* Major rewrite of **::barman** class - No incompatible change introduced
* set **backup_options** to **exclusive_backup**
* added **eyp-epel** and **eyp-postgres** as a requirement

## 0.1.10

* debug flag for **barmanbackup.sh**

## 0.1.9

* bugfix barman 2.0 (archiver = on)

## 0.1.8

* debug info for **barmanbackup**

## 0.1.7

* improved backup error detection for barman backups script

## 0.1.6

* bugfix export script

## 0.1.5

* barman export script

## 0.1.3

* bugfix barman config file
