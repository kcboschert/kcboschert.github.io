+++
date = '2025-05-02T16:03:16-05:00'
draft = false
title = 'High load on Pi-Hole breaks DNS resolution'
tags = ['pihole', 'dns', 'diagnose', 'settings']
+++

I use a [Pi-Hole](https://pi-hole.net/) at home to block ad/tracking/undesired domains, and I recently ran into an issue where it was intermittently causing web pages to fail to load.

The Pi-Hole works as a DNS server. If a domain that's been requested for resolution is in the Pi-Hole's block list, it avoids resolving the domain and returns `0.0.0.0` to the client. It also provides a web UI that you can use to monitor the Pi-Hole and the requests being made against it.

## Diagnosing

After getting `could not resolve host` responses with `curl` and no response with `dig` for some common domains, I opened up the Pi-Hole web UI where I eventually noticed the all-red status text at the top of the page that was casually screaming "LOAD IS SPIKING!" It's usually under 0.2 and now it was above 2.0, so something was definitely up with the Pi-Hole. I ssh'd onto it and took a look at `htop`. The `pihole-FTL` service was using a lot of CPU and memory.

## The Problem

Based on the information I had, I found [this thread from 2019](https://discourse.pi-hole.net/t/pihole-ftl-using-all-my-cpu-and-breaks-all-internet-connectivity/15672/6) which mentioned:

> When pihole-FTL starts, the default behavior is to read the previous 24 hours of data from the long term database.

It also pointed out that the long-term database was stored in `/etc/pihole/pihole-FTL.db`...

`/etc/pihole/pihole-FTL.db` on my Pi-Hole had grown to **1.5Gb**!

This is running on an old Raspberry Pi so it doesn't have a ton of resources. If pihole-FTL is trying to read the entire thing, it's gonna take a while.

## The Fix

The following suggestion from the thread solved the issue, and returned load to its normal levels:

```bash
sudo service pihole-FTL stop
sudo mv /etc/pihole/pihole-FTL.db /etc/pihole/pihole-FTL.db.old
sudo service pihole-FTL start
```

## Bonus Setting

I also took this opportunity to review the settings page of the Pi-Hole, where I discovered there's now an option to disable loading queries from the database on restart:

```
Settings
↳ Privacy
  ↳ Privacy-related database settings
    ↳ Should FTL load queries from the database on (re)start?
```
