(define-fungible-token step-token)

(define-constant contract-owner tx-sender)
(define-constant token-cap u1000000000)
(define-constant err-owner-only (err u100))
(define-constant err-invalid-amount (err u101))
(define-constant err-cap-reached (err u102))

(define-data-var total-supply uint u0)

(define-public (mint (amount uint) (recipient principal))
  (let ((new-supply (+ (var-get total-supply) amount)))
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (<= new-supply token-cap) err-cap-reached)
    (var-set total-supply new-supply)
    (ok (ft-mint? step-token amount recipient))))

(define-public (transfer (amount uint) (recipient principal))
  (ft-transfer? step-token amount tx-sender recipient))

(define-read-only (get-total-supply)
  (ok (var-get total-supply)))
