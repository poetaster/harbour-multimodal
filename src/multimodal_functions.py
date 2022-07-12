# -*- coding: utf-8 -*-
from datetime import datetime, timezone, timedelta

TIMEZONE_UK = 1
TIMEZONE_DE = 2

HOUR_SECONDS = 3600
DAY_SECONDS = 86400

def dst_offset(time_zone, delta_days = None):
  dst = (
    (1648342800, 1667091599), #2022
    (1679792400, 1667005199), #2023
    (1711846800, 1666832399), #2024
    (1743296400, 1666745999), #2025
  )

  dst_offset = 0

  unix_time = datetime.now().timestamp()
  if delta_days:
    unix_time = (datetime.now() + timedelta(days=delta_days)).timestamp()
  for dst_start, dst_end in dst:
    if unix_time >= dst_start and unix_time <= dst_end:
      dst_offset = HOUR_SECONDS

  return dst_offset

def ts_offset(time_zone):
  if time_zone == TIMEZONE_DE:
    return HOUR_SECONDS
  return 0

def hm_to_ts(time_s, time_zone, delta_days = None):
  if delta_days:
    return datetime.strptime((datetime.now() + timedelta(days=delta_days)).replace(tzinfo=timezone.utc).strftime("%Y-%m-%d ") + time_s, '%Y-%m-%d %H:%M').replace(tzinfo=timezone.utc).timestamp() - ts_offset(time_zone) - dst_offset(time_zone, delta_days)
  return datetime.strptime(datetime.now().replace(tzinfo=timezone.utc).strftime("%Y-%m-%d ") + time_s, '%Y-%m-%d %H:%M').replace(tzinfo=timezone.utc).timestamp() - ts_offset(time_zone) - dst_offset(time_zone)

def time_to_utc(time_o, time_zone):
  return time_o.replace(tzinfo=timezone.utc).timestamp() - ts_offset(time_zone) - dst_offset(time_zone)

def timestamp(time_zone = None):
  if not time_zone:
    return datetime.now().timestamp()

  return datetime.now().timestamp() + ts_offset(time_zone) + dst_offset(time_zone)
