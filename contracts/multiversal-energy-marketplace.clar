;; Multiversal Energy Marketplace Contract

(define-fungible-token multiverse-energy-token)

;; Constants
(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_NOT_AUTHORIZED (err u100))
(define-constant ERR_INVALID_LISTING (err u101))
(define-constant ERR_INSUFFICIENT_BALANCE (err u102))

;; Data variables
(define-data-var listing-count uint u0)

;; Data maps
(define-map energy-listings
  uint
  {
    seller: principal,
    universe-origin: (string-ascii 50),
    energy-type: (string-ascii 50),
    amount: uint,
    price: uint,
    expiration: uint
  }
)

;; Public functions
(define-public (create-listing (universe-origin (string-ascii 50)) (energy-type (string-ascii 50)) (amount uint) (price uint) (expiration uint))
  (let
    (
      (listing-id (+ (var-get listing-count) u1))
    )
    (map-set energy-listings
      listing-id
      {
        seller: tx-sender,
        universe-origin: universe-origin,
        energy-type: energy-type,
        amount: amount,
        price: price,
        expiration: (+ block-height expiration)
      }
    )
    (var-set listing-count listing-id)
    (ok listing-id)
  )
)

(define-public (purchase-energy (listing-id uint))
  (let
    (
      (listing (unwrap! (map-get? energy-listings listing-id) ERR_INVALID_LISTING))
      (buyer tx-sender)
    )
    (asserts! (>= (ft-get-balance multiverse-energy-token buyer) (get price listing)) ERR_INSUFFICIENT_BALANCE)
    (asserts! (< block-height (get expiration listing)) ERR_INVALID_LISTING)
    (try! (ft-transfer? multiverse-energy-token (get price listing) buyer (get seller listing)))
    (map-delete energy-listings listing-id)
    (ok true)
  )
)

(define-public (cancel-listing (listing-id uint))
  (let
    (
      (listing (unwrap! (map-get? energy-listings listing-id) ERR_INVALID_LISTING))
    )
    (asserts! (is-eq tx-sender (get seller listing)) ERR_NOT_AUTHORIZED)
    (map-delete energy-listings listing-id)
    (ok true)
  )
)

;; Read-only functions
(define-read-only (get-listing (listing-id uint))
  (map-get? energy-listings listing-id)
)

(define-read-only (get-listing-count)
  (var-get listing-count)
)

