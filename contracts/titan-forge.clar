;; Title: Titan Forge - On-Chain Options Protocol

;; Summary:
;; Titan Forge is a composable, decentralized options trading engine built 
;; for programmable financial derivatives on-chain. It enables users to write, 
;; buy, and exercise CALL and PUT options using any SIP-010 compliant token.
;;
;; Description:
;; Titan Forge supports dynamic collateralization, token whitelisting, and a 
;; permissioned price oracle system. It includes robust validation mechanisms, 
;; error handling, and user position tracking. The contract also supports 
;; administrative controls over fees, asset approvals, and price data feeds.

;; SIP-010 Trait ;;
(define-trait sip-010-trait (
  (transfer
    (uint principal principal (optional (buff 34)))
    (response bool uint)
  )
  (get-balance
    (principal)
    (response uint uint)
  )
  (get-total-supply
    ()
    (response uint uint)
  )
  (get-decimals
    ()
    (response uint uint)
  )
  (get-token-uri
    ()
    (response (optional (string-utf8 256)) uint)
  )
  (get-name
    ()
    (response (string-ascii 32) uint)
  )
  (get-symbol
    ()
    (response (string-ascii 32) uint)
  )
))

;; Error codes
(define-constant ERR-NOT-AUTHORIZED (err u1000))
(define-constant ERR-INSUFFICIENT-BALANCE (err u1001))
(define-constant ERR-INVALID-EXPIRY (err u1002))
(define-constant ERR-INVALID-STRIKE-PRICE (err u1003))
(define-constant ERR-OPTION-NOT-FOUND (err u1004))
(define-constant ERR-OPTION-EXPIRED (err u1005))
(define-constant ERR-INSUFFICIENT-COLLATERAL (err u1006))
(define-constant ERR-ALREADY-EXERCISED (err u1007))
(define-constant ERR-INVALID-PREMIUM (err u1008))

;; Add new error constants for validation
(define-constant ERR-INVALID-TOKEN (err u1009))
(define-constant ERR-INVALID-SYMBOL (err u1010))
(define-constant ERR-INVALID-TIMESTAMP (err u1011))

;; Add validation for admin inputs

;; Add new error constants
(define-constant ERR-INVALID-ADDRESS (err u1012))
(define-constant ERR-ZERO-ADDRESS (err u1013))
(define-constant ERR-EMPTY-SYMBOL (err u1014))

;; Utility Functions
(define-private (get-min
    (a uint)
    (b uint)
  )
  (if (< a b)
    a
    b
  )
)

;; Data Types
(define-map options
  uint
  {
    writer: principal,
    holder: (optional principal),
    collateral-amount: uint,
    strike-price: uint,
    premium: uint,
    expiry: uint,
    is-exercised: bool,
    option-type: (string-ascii 4), ;; "CALL" or "PUT"
    state: (string-ascii 9), ;; Changed to 9 to accommodate "EXERCISED"
  }
)

(define-map user-positions
  principal
  {
    written-options: (list 10 uint),
    held-options: (list 10 uint),
    total-collateral-locked: uint,
  }
)