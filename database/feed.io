Table user_feeds {
  user_id uuid pk
  post_id uuid pk
  created_at timestamp [not null]
}

Table celebrities {
  user_id uuid [primary key]
  followers_count integer [not null]
}

Table popuplar_locations {
  location_id uuid [primary key]
}

Table users {
  user_id uuid pk
  handle text [not null, unique]
  created_at timestamp [not null]
}

Ref: celebrities.user_id > users.user_id
Ref: user_feeds.user_id > users.user_id