;; Inter-Universal Energy Transfer Agreement Contract

;; Constants
(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_NOT_AUTHORIZED (err u100))
(define-constant ERR_INVALID_AGREEMENT (err u101))
(define-constant ERR_INVALID_STATUS (err u102))

;; Data variables
(define-data-var agreement-count uint u0)

;; Data maps
(define-map energy-transfer-agreements
  uint
  {
    initiator: principal,
    recipient-universe: (string-ascii 50),
    energy-amount: uint,
    transfer-method: (string-ascii 100),
    status: (string-ascii 20),
    creation-time: uint,
    execution-time: (optional uint)
  }
)

;; Public functions
(define-public (create-agreement (recipient-universe (string-ascii 50)) (energy-amount uint) (transfer-method (string-ascii 100)))
  (let
    (
      (agreement-id (+ (var-get agreement-count) u1))
    )
    (map-set energy-transfer-agreements
      agreement-id
      {
        initiator: tx-sender,
        recipient-universe: recipient-universe,
        energy-amount: energy-amount,
        transfer-method: transfer-method,
        status: "pending",
        creation-time: block-height,
        execution-time: none
      }
    )
    (var-set agreement-count agreement-id)
    (ok agreement-id)
  )
)

(define-public (execute-agreement (agreement-id uint))
  (let
    (
      (agreement (unwrap! (map-get? energy-transfer-agreements agreement-id) ERR_INVALID_AGREEMENT))
    )
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_NOT_AUTHORIZED)
    (asserts! (is-eq (get status agreement) "pending") ERR_INVALID_STATUS)
    (ok (map-set energy-transfer-agreements
      agreement-id
      (merge agreement {
        status: "executed",
        execution-time: (some block-height)
      })
    ))
  )
)

(define-public (cancel-agreement (agreement-id uint))
  (let
    (
      (agreement (unwrap! (map-get? energy-transfer-agreements agreement-id) ERR_INVALID_AGREEMENT))
    )
    (asserts! (or (is-eq tx-sender (get initiator agreement)) (is-eq tx-sender CONTRACT_OWNER)) ERR_NOT_AUTHORIZED)
    (asserts! (is-eq (get status agreement) "pending") ERR_INVALID_STATUS)
    (ok (map-set energy-transfer-agreements
      agreement-id
      (merge agreement { status: "cancelled" })
    ))
  )
)

;; Read-only functions
(define-read-only (get-agreement (agreement-id uint))
  (map-get? energy-transfer-agreements agreement-id)
)

(define-read-only (get-agreement-count)
  (var-get agreement-count)
)

