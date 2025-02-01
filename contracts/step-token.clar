(define-fungible-token step-token)

(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-invalid-amount (err u101))

(define-public (mint (amount uint) (recipient principal))
  (if (is-eq tx-sender contract-owner)
    (ok (ft-mint? step-token amount recipient))
    err-owner-only))

(define-public (transfer (amount uint) (recipient principal))
  (ft-transfer? step-token amount tx-sender recipient))
