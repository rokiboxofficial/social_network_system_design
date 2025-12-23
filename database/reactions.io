Table follows {
  follower_user_id uuid pk
  followed_user_id uuid pk
  created_at timestamp [not null]
}

Table likes { 
  user_id uuid pk
  post_id uuid pk
  created_at timestamp [not null]
}

Table comments {
  comment_id uuid pk
  user_id uuid [not null]
  post_id uuid [not null]
  created_at timestamp [not null]
  text text [not null]
}