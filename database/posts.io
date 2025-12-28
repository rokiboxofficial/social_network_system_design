Table photos {
  photo_id uuid pk
  user_id uuid [not null]
  content_type text [not null]
  created_at timestamp [not null]
}

Table locations {
  location_id uuid pk
  latitude double [not null]
  longitude double [not null]
  title text [not null]
}

Table posts {
  post_id uuid pk
  created_at timestamp [not null]
  user_id uuid [not null]
  location_id uuid [not null]
  description text
}

Table posts_photos {
  post_id uuid pk
  photo_id uuid pk
}

Ref: posts_photos.post_id > posts.post_id
Ref: posts_photos.photo_id > photos.photo_id
Ref: posts.location_id > locations.location_id