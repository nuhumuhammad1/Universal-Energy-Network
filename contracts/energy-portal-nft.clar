;; Energy Portal NFT Contract

(define-non-fungible-token energy-portal-nft uint)

;; Constants
(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_NOT_AUTHORIZED (err u100))
(define-constant ERR_INVALID_NFT (err u101))

;; Data variables
(define-data-var last-token-id uint u0)

;; Data maps
(define-map token-metadata
  uint
  {
    creator: principal,
    portal-type: (string-ascii 50),
    description: (string-utf8 500),
    capacity: uint,
    stability: uint,
    connected-universes: (list 5 (string-ascii 50)),
    creation-time: uint
  }
)

;; Public functions
(define-public (mint-energy-portal (portal-type (string-ascii 50)) (description (string-utf8 500)) (capacity uint) (stability uint) (connected-universes (list 5 (string-ascii 50))))
  (let
    (
      (token-id (+ (var-get last-token-id) u1))
    )
    (asserts! (and (>= stability u0) (<= stability u100)) ERR_NOT_AUTHORIZED)
    (try! (nft-mint? energy-portal-nft token-id tx-sender))
    (map-set token-metadata
      token-id
      {
        creator: tx-sender,
        portal-type: portal-type,
        description: description,
        capacity: capacity,
        stability: stability,
        connected-universes: connected-universes,
        creation-time: block-height
      }
    )
    (var-set last-token-id token-id)
    (ok token-id)
  )
)

(define-public (transfer-energy-portal (token-id uint) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender (unwrap! (nft-get-owner? energy-portal-nft token-id) ERR_INVALID_NFT)) ERR_NOT_AUTHORIZED)
    (try! (nft-transfer? energy-portal-nft token-id tx-sender recipient))
    (ok true)
  )
)

;; Read-only functions
(define-read-only (get-energy-portal-metadata (token-id uint))
  (map-get? token-metadata token-id)
)

(define-read-only (get-energy-portal-owner (token-id uint))
  (nft-get-owner? energy-portal-nft token-id)
)

(define-read-only (get-last-token-id)
  (var-get last-token-id)
)

