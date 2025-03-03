(define-map profiles
  { user: principal }
  {
    name: (string-utf8 50),
    bio: (string-utf8 200),
    total-distance: uint,
    routes-completed: uint,
    last-updated: uint
  })

(define-public (create-profile (name (string-utf8 50)) (bio (string-utf8 200)))
  (ok (map-insert profiles
    { user: tx-sender }
    {
      name: name,
      bio: bio,
      total-distance: u0,
      routes-completed: u0,
      last-updated: block-height
    })))

(define-public (update-profile (name (string-utf8 50)) (bio (string-utf8 200)))
  (ok (map-set profiles
    { user: tx-sender }
    {
      name: name,
      bio: bio,
      total-distance: u0,
      routes-completed: u0,
      last-updated: block-height
    })))

(define-read-only (get-profile (user principal))
  (map-get? profiles { user: user }))
