# Travelers - System Design

Homework for https://balun.courses/courses/system_design.
Travelers is a social network that allows users to share their experiences and be inspired by those of others.

## Functional requirements:
- Publish travel reports that include photos, a description, and a location
- Like and comment on posts created by other users
- Follow other users
- Discover popular places based on aggregated activity
- View a feed of posts related to a selected popular place
- View their own feed or another users feed in reverse chronological order

## Non-functional requirements:
- 10,000,000 DAU with linear user growth
- Availability: 99.99%
- All content (posts, likes, etc.) is permanently stored
- The system must be easy to use on both mobile and web
- Targeting users in the CIS region
- Exhibits seasonal traffic patterns (e.g., vacations)
- During peak seasons, average user activity increases by 1.5
- Average user:
  - Views 100 posts daily
  - Views 10 comments per 5 posts daily
  - Views 2 photos per post daily
  - Likes 90 posts daily
  - Comments on 5 posts daily
  - Creates 1 post with 3 photos every 2 weeks
  - Follows 1 user every 2 days
  - Performs 20 location searches per month
- Average post has 10 comments
- Page size is 20 for all lists
- Maximum posts per user: 100,000
- Maximum photo size: 8 MB
- Performance:
  - A post, like, or comment should be visible to other users within 10 seconds
  - Retrieving a page of posts or comments should take less than 1 second

## Basic structure sizes

Post (322 bytes):

    id: 16
    created_at: 8
    user_handle: 30
    description: 200
    location: 16
    photos: 3 * 16
    likes: 4

Comment (254 bytes):

    id: 16
    created_at: 8
    user_handle: 30
    text: 200

Popular location (82 bytes):

    id: 16
    location: 16
    title: 50
  
Photo (500 KB):

    id: 16
    content: 500KB

## Basic calculations:
Details such as the difference between the size of the write or read structures, as well as individual responses in the form of the created entity ID, are not taken into account. This is an overview.
There are calculations for average day. Multiply by 1.5 to get RPS or traffic during peak season.

Posts feed:

    read RPS: (10,000,000 * (100 / 20)) / 86,400 ≈ 579
    read traffic: 579 * 20 * 322 ≈ 3.7 MB/s
    
    write RPS: (10,000,000 * (1 / 14)) / 86,400 ≈ 8
    write traffic: 8 * 322 ≈ 2.6 KB/s

Comments:

    read RPS: (10,000,000 * ((100 / 5))) / 86,400 ≈ 2,314
    read traffic: 2,314 * 20 * 254 ≈ 12 MB/s

    write RPS: (10,000,000 * 5) / 86,400 ≈ 579
    write traffic: 579 * 254 ≈ 147 KB/s

Likes:

    write RPS: (10,000,000 * 90) / 86,400 ≈ 10,417 
    write traffic: negligible (protocol headers only)

Subscribers:
  
    write RPS: (10,000,000 * 0.5) / 86,400 ≈ 58
    write traffic: negligible (protocol headers only)

Photos:

    read RPS: (10,000,000 * 100 * 2) / 86,400 ≈ 23,148
    read traffic: 23,148 * 500 KB ≈ 11.6 GB/s
    
    write RPS: (10,000,000 * (1/14) * 3) / 86,400 ≈ 25
    write traffic: 25 * 500 KB ≈ 12.5 MB/s

Popular places search:

    read RPS: (10,000,000 * (20/30)) / 86,400 ≈ 77
    read traffic: 77 * 82 ≈ 6.3 KB/s

### Basic calculations summary:
Media content drives extremely high read traffic, and the system overall is read-heavy, with reads far exceeding writes.

## Disks calculations:
Posts:

    Capacity_for_year = 2.6 KB/s * 86,400 * 365 ≈ 82 GB
    Disks_for_capacity = 82 GB / 2 TB ≈ 0.041
    Disks_for_throughput = (2.6 KB/s + 3.7 MB/s) / 100 MB/s ≈ 0.04
    Disks_for_iops = (579/s + 8/s) / 100 ≈ 5.87
    Disks = max(1, 1, 6) ≈ 6

Comments:

    Capacity_for_year = 147 KB/s * 86,400 * 365 ≈ 4.6 TB
    Disks_for_capacity = 4.6 TB / 8 TB ≈ 0.57
    Disks_for_throughput = (147 KB/s + 12 MB/s) / 500 MB/s ≈ 0.02
    Disks_for_iops = (579/s + 2,314/s) / 1000 ≈ 2.9
    Disks (SSD SATA) = max(1, 1, 3) = 3

Likes:

    Capacity_for_year = 10,417/s * 172 B (size of row in db) * 86,400 * 365 ≈ 56.5 TB
    Disks_for_capacity = 56.5 TB / 100 TB ≈ 0.56
    Disks_for_throughput = (10,417/s * 172 B) / 500 MB/s ≈ 0.01
    Disks_for_iops = 10,417/s / 1000 ≈ 10.4
    Disks (SSD SATA) = max(1, 1, 11) = 11

Subscribers:

    Capacity_for_year = 58/s * 36 B (size of row in db) * 86,400 * 365 ≈ 66 GB
    Disks_for_capacity = 66 GB / 2 TB ≈ 0.03
    Disks_for_throughput = (58/s * 36 B) / 100 MB/s ≈ 0.01
    Disks_for_iops = 58/s / 100 ≈ 0.58
    Disks = max(1, 1, 1) ≈ 1

Photos:

    Capacity_for_external_storage = 12.5 MB/s * 86,400 * 365 ≈ 394 TB (cloud storage)
    Db_capacity_for_year = 82 B (size of row in db) * 25/s * 86,400 * 365 ≈ 64.6 GB
    Disks_for_capacity = 64.6 GB / 2 TB ≈ 0.03
    Disks_for_throughput = (82 B * 25/s ) / 100 MB/s ≈ 0.01
    Disks_for_iops = 25/s / 100 ≈ 0.25
    Disks (SSD SATA) = max(1, 1, 1) ≈ 1

Locations:

    Capacity = 58,500,000 (count of households in Russia) * 52 B (size of row in db) = 3 GB
    Disks_for_capacity = 3 GB / 2 TB ≈ 0.01
    Disks_for_throughput = 6.3 KB/s / 100 MB/s ≈ 0.01
    Disks_for_iops = 77/s / 100 ≈ 0.77
    Disks = max(1, 1, 1) ≈ 1
