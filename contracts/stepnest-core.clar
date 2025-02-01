(define-map routes
  { route-id: uint }
  {
    creator: principal,
    name: (string-utf8 100),
    description: (string-utf8 500),
    distance: uint,
    difficulty: uint,
    rating: uint,
    total-reviews: uint
  })

(define-map user-completed-routes
  { user: principal, route-id: uint }
  { completed: bool, timestamp: uint })

(define-data-var next-route-id uint u0)

(define-public (create-route (name (string-utf8 100)) (description (string-utf8 500)) (distance uint) (difficulty uint))
  (let ((route-id (var-get next-route-id)))
    (map-insert routes
      { route-id: route-id }
      {
        creator: tx-sender,
        name: name,
        description: description,
        distance: distance,
        difficulty: difficulty,
        rating: u0,
        total-reviews: u0
      })
    (var-set next-route-id (+ route-id u1))
    (ok route-id)))

(define-public (complete-route (route-id uint))
  (map-set user-completed-routes
    { user: tx-sender, route-id: route-id }
    { completed: true, timestamp: block-height })
  (contract-call? .step-token mint u100 tx-sender))
