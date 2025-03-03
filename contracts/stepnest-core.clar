;; Constants
(define-constant ERR-NOT-FOUND (err u404))
(define-constant ERR-UNAUTHORIZED (err u401))
(define-constant ERR-ALREADY-COMPLETED (err u402))
(define-constant ERR-INVALID-RATING (err u403))

;; Events
(define-data-var contract-paused bool false)

(define-map routes
  { route-id: uint }
  {
    creator: principal,
    name: (string-utf8 100),
    description: (string-utf8 500),
    distance: uint,
    difficulty: uint,
    rating: uint,
    total-reviews: uint,
    category: (string-utf8 50)
  })

(define-map user-completed-routes
  { user: principal, route-id: uint }
  { completed: bool, timestamp: uint })

(define-map route-reviews
  { route-id: uint, reviewer: principal }
  { rating: uint, review-text: (string-utf8 500), timestamp: uint })

(define-data-var next-route-id uint u0)

;; Administrative Functions
(define-public (set-paused (paused bool))
  (begin
    (asserts! (is-eq tx-sender contract-owner) ERR-UNAUTHORIZED)
    (ok (var-set contract-paused paused))))

(define-public (create-route (name (string-utf8 100)) 
                           (description (string-utf8 500)) 
                           (distance uint) 
                           (difficulty uint)
                           (category (string-utf8 50)))
  (begin
    (asserts! (not (var-get contract-paused)) ERR-UNAUTHORIZED)
    (asserts! (and (>= difficulty u1) (<= difficulty u5)) ERR-INVALID-RATING)
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
          total-reviews: u0,
          category: category
        })
      (var-set next-route-id (+ route-id u1))
      (print { type: "route-created", route-id: route-id, creator: tx-sender })
      (ok route-id))))

(define-public (update-route (route-id uint) 
                           (name (string-utf8 100)) 
                           (description (string-utf8 500)))
  (let ((route (unwrap! (map-get? routes { route-id: route-id }) ERR-NOT-FOUND)))
    (asserts! (not (var-get contract-paused)) ERR-UNAUTHORIZED)
    (asserts! (is-eq (get creator route) tx-sender) ERR-UNAUTHORIZED)
    (ok (map-set routes
      { route-id: route-id }
      (merge route { name: name, description: description })))))

(define-public (complete-route (route-id uint))
  (let ((completion-check (map-get? user-completed-routes 
                                  { user: tx-sender, route-id: route-id }))
        (route (unwrap! (map-get? routes { route-id: route-id }) ERR-NOT-FOUND)))
    (asserts! (not (var-get contract-paused)) ERR-UNAUTHORIZED)
    (asserts! (is-none completion-check) ERR-ALREADY-COMPLETED)
    (map-set user-completed-routes
      { user: tx-sender, route-id: route-id }
      { completed: true, timestamp: block-height })
    (print { type: "route-completed", user: tx-sender, route-id: route-id })
    (contract-call? .user-profile update-stats (get distance route))
    (contract-call? .step-token mint u100 tx-sender)))

(define-public (add-review (route-id uint) 
                         (rating uint) 
                         (review-text (string-utf8 500)))
  (let ((route (unwrap! (map-get? routes { route-id: route-id }) ERR-NOT-FOUND))
        (completion-check (unwrap! (map-get? user-completed-routes 
                                           { user: tx-sender, route-id: route-id }) 
                                 ERR-UNAUTHORIZED)))
    (asserts! (not (var-get contract-paused)) ERR-UNAUTHORIZED)
    (asserts! (and (>= rating u1) (<= rating u5)) ERR-INVALID-RATING)
    (asserts! (get completed completion-check) ERR-UNAUTHORIZED)
    (map-set route-reviews
      { route-id: route-id, reviewer: tx-sender }
      { rating: rating, 
        review-text: review-text, 
        timestamp: block-height })
    (let ((new-total-reviews (+ (get total-reviews route) u1))
          (new-rating (/ (+ (* (get rating route) (get total-reviews route)) rating)
                       new-total-reviews)))
      (map-set routes
        { route-id: route-id }
        (merge route {
          rating: new-rating,
          total-reviews: new-total-reviews
        })))
    (print { type: "review-added", route-id: route-id, reviewer: tx-sender })
    (ok true)))
