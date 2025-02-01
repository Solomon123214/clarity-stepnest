(define-map profiles
  { user: principal }
  {
    name: (string-utf8 50),
    bio: (string-utf8 200),
    total-distance: uint,
    routes-completed: uint
  })

(define-public (create-profile (name (string-utf8 50)) (bio (string-utf8 200)))
  (ok (map-insert profiles
    { user: tx-sender }
    {
      name: name,
      bio: bio,
      total-distance: u0,
      routes-completed: u0
    })))

(define-read-only (get-profile (user principal))
  (map-get? profiles { user: user }))
